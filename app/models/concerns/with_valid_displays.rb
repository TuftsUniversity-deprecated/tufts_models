module WithValidDisplays
  extend ActiveSupport::Concern
  included do
    validates :displays, presence: true
    validate :displays_valid
  end

  protected

    def displays_valid
      return unless displays.present?
      unless displays.all? {|d| %w(dl tisch perseus elections dark trove).include? d }
        errors.add(:displays, "must be in the list")
      end
    end
end
