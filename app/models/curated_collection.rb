class CuratedCollection < ActiveFedora::Base
  include BaseModel
  include WithValidDisplays

  validates :title, presence: true
  after_initialize :default_attributes
  has_metadata 'collectionMetadata', type: CollectionMetadata

  delegate :members, :member_ids, to: :collectionMetadata

  private
    def default_attributes
      self.displays = ['tdil'] if displays.empty?
    end
end
