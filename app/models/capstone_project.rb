class CapstoneProject < Contribution
  attr_accessor :degree
  validates :degree, presence: true

  protected

  def self.attributes
    super + [:degree]
  end

  def copy_attributes
    super
    @tufts_pdf.subject = degree
  end

  def self.ignore_attributes
    super + [:degree]
  end
end
