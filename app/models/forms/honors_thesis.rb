class HonorsThesis < Contribution
  self.attributes += [:department]
  self.ignore_attributes += [:department]
  attr_accessor :department
  validates :department, presence: true

  protected
  def copy_attributes
    super
    @tufts_pdf.subject = department
  end
end
