class CuratedCollection < ActiveFedora::Base
  include Hydra::ModelMethods
  include Hydra::AccessControls::Permissions
  include WithValidDisplays
  include CollectionMember
  include WithParent

  validates :title, presence: true
  after_initialize :default_attributes

  has_metadata "DCA-META", type: TuftsDcaMeta
  has_metadata 'collectionMetadata', type: CollectionMetadata
  has_metadata "DCA-ADMIN", type: DcaAdmin

  has_attributes :creator, :description, :date_created, datastream: 'DCA-META', multiple: true
  has_attributes :title, datastream: 'DCA-META', multiple: false

  has_attributes :createdby, datastream: 'DCA-ADMIN', multiple: false
  has_attributes :displays, datastream: 'DCA-ADMIN', multiple: true

  delegate :members, :member_ids, :members=, :member_ids=, to: :collectionMetadata
  delegate :delete_member_at, to: :collectionMetadata

  def initialize(attributes = {})
    attributes = { namespace: 'tufts.uc' }.merge(attributes)
    super
  end

  def to_solr(solr_doc=Hash.new)
    super.tap do |solr_doc|
      solr_doc[solr_name('member_ids', :symbol)] = member_ids.map(&:value)
    end
  end

  def to_s
    title
  end

  def parent_count
    query = ActiveFedora::SolrService.construct_query_for_rel(member_ids: self.id)
    ActiveFedora::SolrService.count query
  end

  ##
  # flatten the collection recursively
  def flatten(list = members)
    first, *rest = *list
    if first.nil?
      []
    elsif first.respond_to? :flatten # it's a collection
      first.flatten + flatten(rest)
    else
      [first] + flatten(rest)
    end
  end

  def self.not_containing(pid)
    where(["-member_ids_ssim:\"#{pid}\""])
  end

  private
    def default_attributes
      self.displays = [CollectionInfo.displays_in] if displays.empty?
    end
end
