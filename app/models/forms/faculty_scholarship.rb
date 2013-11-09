class FacultyScholarship < Contribution
  self.attributes += [:other_authors]
  self.ignore_attributes += [:other_authors]
  attr_accessor *attributes

  protected
  def copy_attributes
    super
    @tufts_pdf.creator += [other_authors] if other_authors
  end
end
