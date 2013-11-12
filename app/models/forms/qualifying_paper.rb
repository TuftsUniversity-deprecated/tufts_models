class QualifyingPaper < Contribution
  self.ignore_attributes += [:description]

  protected

  def copy_attributes
    super
    @tufts_pdf.description = "A qualifying paper submitted in partial fulfillment of the requirements for the degree of Doctor of Philosophy in CATALOGER-FIX-ME Education. Abstract: #{description}"
  end

  def source
    'UA071'
  end
end
