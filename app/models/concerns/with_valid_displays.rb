module WithValidDisplays
  extend ActiveSupport::Concern
  included do
    validates :displays, presence: true
    validate :displays_valid
  end

  def displays_options
    Qa::Authorities::Local.subauthority_for('displays'.freeze).all.map { |t| t['label'.freeze] }
  end

  protected

    def displays_valid
      return unless displays.present?
      unless displays.all? {|d| displays_options.include? d }
        errors.add(:displays, "must include at least one valid entry")
      end
    end

end
