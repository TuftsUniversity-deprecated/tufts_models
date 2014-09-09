class CollectionMetadata < ActiveFedora::NtriplesRDFDatastream

  property :member_list, predicate: RDF::DC.relation, class_name: 'ActiveTriples::List'

  def members(force_reload = false)
    reset if force_reload
    @target ||= CollectionProxy.new(member_ids)
  end

  def reset
    @target = nil
  end

  def members=(objects)
    reset
    self.member_ids = objects.map(&:pid)
  end

  def member_ids
    member_list.first_or_create
  end

  def member_ids= ids
    member_ids.clear()
    ids.each do |id|
      member_ids << id
    end
  end

  def delete_member_at(index)
    new_members = members.to_ary
    new_members.delete_at(index)
    self.members = new_members
  end

  def serialize!
    member_ids.resource.persist! #https://github.com/projecthydra/active_fedora/issues/444
    super
  end

end


class CollectionProxy
  include Enumerable

  def initialize(list)
    @list = list
  end

  def [](index)
    pid = ids[index]
    ActiveFedora::Base.find(pid.to_s)
  end

  def ids
    @list.to_a
  end

  def append(*objects)
    @ids = nil
    objects.each do |o|
      @list << o.pid
    end
  end
  alias_method :<<, :append

  def ==(other)
    to_ary == other
  end

  def to_ary
    not_found_ids = []
    members = ids.map do |pid|
      begin
        ActiveFedora::Base.find(pid.to_s)
      rescue ActiveFedora::ObjectNotFoundError
        not_found_ids << pid
        nil
      end
    end.compact

    remove_missing_members(not_found_ids)
    members
  end

  delegate :each, :each_with_index, to: :to_ary
  delegate :empty?, :size, to: :@list

  private

    def remove_missing_members(not_found_ids)
      return if not_found_ids.empty?
      keep_ids = ids - not_found_ids
      @list.clear
      keep_ids.each do |id|
        @list << id
      end
    end
end
