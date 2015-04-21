class TuftsBase < ActiveFedora::Base
  include BaseModel
  include Publishable
  include AttachedFiles
  include Reviewable
  include BatchUpdate
  include WithValidDisplays
  validates :title, presence: true
  has_attributes :batch_id, datastream: 'DCA-ADMIN', multiple: true

end
