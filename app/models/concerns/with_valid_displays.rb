module WithValidDisplays
  extend ActiveSupport::Concern
  included do
    validates :displays, presence: true
    validate :displays_valid
  end

  protected

    def displays_valid
      return unless displays.present?
      unless displays.all? {|d| %w(dl tisch perseus elections dark trove nowhere).include? d }
        errors.add(:displays, "must include at least one valid entry")
      end
    end
end
