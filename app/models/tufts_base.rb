class TuftsBase < ActiveFedora::Base
  include BaseModel
  include Publishable
  include AttachedFiles
  include Reviewable
  include BatchUpdate
  include WithValidDisplays
  validates :title, presence: true
  property :batch_id, delegate_to: 'DCA-ADMIN', multiple: true
end
