class HonorsThesis < Contribution
  attr_accessor :department
  validates :department, presence: true

  protected
  def self.attributes
    super + [:department]
  end

  def copy_attributes
    super
    @tufts_pdf.subject = department
  end

  def self.ignore_attributes
    super + [:department]
  end

end
