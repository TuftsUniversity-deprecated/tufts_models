class CuratedCollection < ActiveFedora::Base
  include WithValidDisplays

  validates :title, presence: true
  after_initialize :default_attributes

  has_metadata "DCA-META", type: TuftsDcaMeta
  has_metadata 'collectionMetadata', type: CollectionMetadata
  has_metadata "DCA-ADMIN", type: DcaAdmin

  has_attributes :creator, :description, :date_created, datastream: 'DCA-META', multiple: true
  has_attributes :title, datastream: 'DCA-META', multiple: false
  has_attributes :displays, datastream: 'DCA-ADMIN', multiple: true

  delegate :members, :member_ids, to: :collectionMetadata

  private
    def default_attributes
      self.displays = ['tdil'] if displays.empty?
    end
end
