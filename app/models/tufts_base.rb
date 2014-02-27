class TuftsBase < ActiveFedora::Base
  include BaseModel

  validates :title, presence: true
  validate :displays_valid
  
protected

  def displays_valid
    return unless displays.present?
    unless displays.all? {|d| %w(dl tisch aah perseus elections dark).include? d }
      errors.add(:displays, "must be in the list")
    end
  end

end
