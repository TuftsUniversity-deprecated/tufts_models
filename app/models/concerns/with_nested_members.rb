module WithNestedMembers
  extend ActiveSupport::Concern

  included do
    before_destroy :destroy_child_collections
  end

  # given a personal or course collection, remove a the first instance of a member by pid
  # makes no change to the collection if pid
  #TODO Move this to CuratedCollection in tufts_models ?
  def delete_member_by_id(pid)
    if posn = member_ids.index(pid)
      delete_member_at(posn)
    end
  end

  # this sets all the members of a collection (images and collections)
  # any that are not provided are removed.
  def member_attributes=(members)
    members = members.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if members.is_a? Hash
    self.member_ids = members.sort_by { |e| e['weight'].to_i }.map { |e| e['id'] }
  end

  # this sets just the collection members of a collection.
  # any collection that is not provided is removed. Images members are preserved
  def collection_attributes=(members)
    members = members.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if members.is_a? Hash
    assign_tree(make_tree(members))
  end

  # update the nested collections with attributes arranged in a tree structure.
  # @see make_tree
  def assign_tree(tree)
    nodes = tree.sort_by { |e| e['weight'].to_i }
    new_collection_ids = nodes.map { |e| e['id'] }
    if ordered_subset?(new_collection_ids)
      removed_collection_ids = collection_member_ids - new_collection_ids
      self.member_ids = (member_ids.map(&:to_s) - removed_collection_ids) unless removed_collection_ids.empty?
    else
      self.member_ids = new_collection_ids + noncollection_member_ids
    end
    nodes.each do |node|
      b = ActiveFedora::Base.find(node['id'])
      b.assign_tree node['children']
      b.save! #TODO We could move this save into an after_save hook.
    end
  end

  def representative_image
    return child_images.first unless child_images.empty?
    child_collections.each do |c|
      img = c.representative_image
      return img unless img.nil?
    end
    nil
  end

  # Return the children of this collection that are collections themselves
  def child_collections
    members.select {|m| m.kind_of? CuratedCollection }
  end

  # returns a lazy, ordered list of all members (all leaf nodes of the tree)
  def flattened_member_ids
    flattened_member_ids_with_collections.map(&:first)
  end

  # returns a lazy, ordered list of all members (all leaf nodes of the tree) and their parent collections
  def flattened_member_ids_with_collections(pids=nil, parent_collection=nil)
    # logger.info "WithNestedMembers.flatten_pids_via_solr: querying for #{pids.inspect}"

    # default to info from this collection
    if pids.nil?
      pids = member_ids
    end
    if parent_collection.nil?
      query = ActiveFedora::SolrService.construct_query_for_pids([pid])
      parent_collection = ActiveFedora::SolrService.query(query).first
    end

    # make sure pids aren't RDFLiterals
    pids = pids.map(&:to_s)

    # load many docs at once so we have fewer requests
    query = ActiveFedora::SolrService.construct_query_for_pids(pids)
    docs = ActiveFedora::SolrService.query(query, rows: pids.count).reduce({}) do |acc,doc|
      acc.merge!(doc['id'] => doc)
    end

    model_attr = ActiveFedora::SolrService.solr_name("has_model", :symbol)
    pids.
      # don't do queries for all pids if we only need the first few
      lazy.
      # this is needed because member_ids sometimes returns deleted pids
      # see https://github.com/curationexperts/tufts_models/issues/8
      select{|pid| ActiveFedora::Base.exists?(pid)}.
      flat_map do |pid|
        doc = docs[pid]
        class_uri = doc[model_attr].first
        if [PersonalCollection, CourseCollection].map(&:to_class_uri).include? class_uri
          # this pid is a collection
          flattened_member_ids_with_collections(ActiveFedora::Base.find(pid).member_ids, doc)
        else
          # this pid is a non-collection
          [[pid, parent_collection]]
        end
      end
  end

  # find the positions of all the members in the root collection (and their parent)
  def positions_of_members
    image_positions = flattened_member_ids_with_collections.
      # keep only the parent collections
      map(&:second).
      # add positions
      with_index.
      # keep only the children of this collection
      select { |(parent, _)| parent['id'] == pid }.
      # keep only the positions
      map(&:second)
    # collections don't have positions when going through a flattened collection, put nils in for
    # the positions of collections
    member_positions = []
    members.map do |member|
      if member.is_a? CuratedCollection
        member_positions << nil
      else
        # parents_of_members looks like this: [[parent, position], ...]
        # using .next here because .drop(1) causes the internal pointer to rewind
        # which makes us query for the dropped item a second time
        member_positions << image_positions.next
      end
    end
    member_positions
  end

  protected

    def proxy
      @proxy ||= CollectionSolrProxy.new(id: id, member_ids: member_ids.map(&:to_s), klass: self.class)
    end

    delegate :collection_member_ids, :noncollection_member_ids, to: :proxy

    def ordered_subset?(new_ids)
      positions = new_ids.map { |new_id| member_ids.find_index(new_id) }
      min = -1
      positions.each do |pos|
        return false if pos.nil? || pos < min
        min = pos
      end
      true
    end

    # Takes in a linked list with parent pointers and transforms it to a tree
    def make_tree(in_list, pid = self.pid)
      [].tap do |top_level|
        left_over = []
        # Categorize into top level, or not top level
        in_list.each do |node|
          if node['parent_page_id'].blank? || node['parent_page_id'] == pid
            top_level.unshift node
          else
            left_over.unshift node
          end
        end

        # For each of the top_level nodes make a subtree with the leftovers.
        top_level.each do |node|
          node['children'] = make_tree(left_over, node['id'])
        end
      end
    end

    def destroy_child_collections
      child_collections.each(&:destroy)
    end

    def child_images
      @child_images ||= members.select {|m| (m.kind_of?(TuftsVideo) || m.kind_of?(TuftsImage))}
    end
end
