class HonorsThesis < Contribution
  self.attributes += [:department]
  self.ignore_attributes += [:department]
  attr_accessor :department
  validates :department, presence: true

  protected
  def copy_attributes
    super
    @tufts_pdf.subject = department
    @tufts_pdf.creatordept = creatordept
  end

  private

  def creatordept
    terms = Qa::Authorities::Local.sub_authority('departments').terms
    if term = terms.find { |t| t[:term] == department }
      term[:id]
    else
      'NEEDS FIXING'
    end
  end
end
