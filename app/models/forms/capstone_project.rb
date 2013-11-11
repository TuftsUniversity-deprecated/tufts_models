class CapstoneProject < Contribution
  self.attributes += [:degree]
  self.ignore_attributes += [:degree]
  attr_accessor :degree
  validates :degree, presence: true

  protected

  def copy_attributes
    super
    @tufts_pdf.subject = degree
  end
end
