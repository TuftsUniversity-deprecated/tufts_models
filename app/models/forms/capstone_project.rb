class CapstoneProject < Contribution
  self.attributes += [:degree]
  self.ignore_attributes += [:degree, :description]
  attr_accessor :degree
  validates :degree, presence: true

  protected

  def copy_attributes
    super
    @tufts_pdf.description = "Submitted in partial fulfillment of the degree #{long_degree} at the Fletcher School of Law and Diplomacy. Abstract: #{description}"
    @tufts_pdf.subject = degree
  end

  private

  def long_degree
    Qa::Authorities::Local.sub_authority('fletcher_degrees').full_record(degree)[:term]
  end
end
