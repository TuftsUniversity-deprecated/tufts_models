class CollectionSolrProxy

  attr_reader :id

  def initialize(attrs, _=nil)
    @id = attrs.delete(:id)
    if @loaded = attrs.key?('has_model_ssim')
      # this is a full solr document
      @properties = result_to_properties(attrs)
    elsif !attrs.empty?
      # this is just klass and member_ids
      @properties = attrs
    end
  end

  def collection_member_ids
    @collection_member_ids ||= begin
      return [] if member_ids.blank?
      member_results = ActiveFedora::SolrService.query(collection_member_query, fl: 'id', rows: 1000)
      collection_ids = member_results.map { |result| result['id'] }
      member_ids & collection_ids
    end
  end

  def collection_members
    @collection_members ||= begin
      collection_member_ids.map { |member_id| self.class.new(id: member_id) }
    end
  end

  def noncollection_member_ids
    @noncollection_member_ids ||= begin
      return [] if member_ids.empty?
      ActiveFedora::SolrService.query(noncollection_member_query, fl: 'id', rows: 1000).map { |result| result['id'] }
    end
  end

  def exists?
    fetch_properties unless @loaded
    @loaded
  end

  # This is used by form_for to determine whether to use :patch or :post as the method
  def persisted?
    exists?
  end

  def == other
    other.class == self.class && id == other.id
  end

  def title
    properties[:title]
  end

  def member_ids
    properties[:member_ids]
  end

  def klass
    properties[:klass]
  end

  def to_param
    id
  end

  def to_key
    [id]
  end

  private
    def collection_member_query
      ['(' + ActiveFedora::SolrService.construct_query_for_pids(member_ids) + ')',
       ActiveFedora::SolrService.construct_query_for_rel(has_model: klass.to_class_uri)
      ].join(' AND ')
    end

    def noncollection_member_query
      ['(' + ActiveFedora::SolrService.construct_query_for_pids(member_ids.map(&:to_s)) + ')',
       ActiveFedora::SolrService.construct_query_for_rel(has_model: TuftsImage.to_class_uri)].
      join(' AND ')
    end

    def properties
      @properties || fetch_properties
    end

    def fetch_properties
      query = ActiveFedora::SolrService.raw_query( SOLR_DOCUMENT_ID, @id)
      result = ActiveFedora::SolrService.query(query, fl: 'id member_ids_ssim title_tesim has_model_ssim').first
      return {} if result.nil?
      @loaded = true
      @properties = result_to_properties(result)
    end

    def result_to_properties(result)
      {
        member_ids: result['member_ids_ssim'],
        klass:      ActiveFedora::Model.from_class_uri(result['has_model_ssim'].first),
        title:      result['title_tesim'].first
      }
    end
end
