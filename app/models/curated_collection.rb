class CuratedCollection < ActiveFedora::Base
#TODO -- wtf  include Hydra::ModelMethods
  include Hydra::AccessControls::Permissions
  include WithValidDisplays
  include CollectionMember
  include WithParent

  validates :title, presence: true
  after_initialize :default_attributes

  contains "DCA-META", class_name: 'TuftsDcaMeta'
  contains 'collectionMetadata', class_name: 'CollectionMetadata'
  contains "DCA-ADMIN", class_name: 'DcaAdmin'

  property :creator, delegate_to: 'DCA-META', multiple: true
  property :title, delegate_to: 'DCA-META', multiple: false

  property :createdBy, delegate_to: 'DCA-ADMIN', multiple: false
  property :displays, delegate_to: 'DCA-ADMIN', multiple: true

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
