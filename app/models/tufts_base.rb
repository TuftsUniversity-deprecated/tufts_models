class TuftsBase < ActiveFedora::Base
  include BaseModel
  include AttachedFiles
  include Reviewable

  validates :title, presence: true
  validates :displays, presence: true
  validate :displays_valid

  has_attributes :batch_id, datastream: 'DCA-ADMIN', multiple: true
  
protected

  def displays_valid
    return unless displays.present?
    unless displays.all? {|d| %w(dl tisch aah perseus elections dark).include? d }
      errors.add(:displays, "must be in the list")
    end
  end

end
