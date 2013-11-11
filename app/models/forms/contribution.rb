class Contribution
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  validates :title, presence: true, length: {maximum: 250}
  validates :description, presence: true, length: {maximum: 2000}
  validates :creator, presence: true
  validates :attachment, presence: true

  class_attribute :ignore_attributes, :attributes
  
  self.ignore_attributes = [:attachment]

  self.attributes = [:title, :description, :creator, :contributor, 
                     :bibliographic_citation, :subject, :attachment, :license]

  SELFDEP = 'selfdep'.freeze

  def persisted?
    false
  end

  def tufts_pdf
    return @tufts_pdf if @tufts_pdf
    now = Time.now

    note = "#{creator} self-deposited on #{now.strftime('%Y-%m-%d at %H:%M:%S %Z')} using the Deposit Form for the Tufts Digital Library"
    @tufts_pdf = TuftsPdf.new(pid: Sequence.next_val, createdby: SELFDEP, 
                    steward: 'dca', displays: 'dl', format: 'application/pdf',
                    publisher: 'Tufts University. Digital Collections and Archives.',
                    rights: 'http://dca.tufts.edu/ua/access/rights-creator.html',
                    date_available: now.to_s, date_submitted: now.to_s, note: note)

    copy_attributes
    @tufts_pdf
  end

  def initialize(data = {})
    self.class.attributes.each do |attribute|
      send("#{attribute}=", data[attribute])
    end
  end

  def save
    return false unless valid?
    tufts_pdf.store_archival_file('Archival.pdf', attachment)
    tufts_pdf.save!
    tufts_pdf
  end

  def self.create(attrs)
    form = self.new(attrs)
    form.save
  end

  protected

  def copy_attributes
    (self.class.attributes - self.class.ignore_attributes).each do |attribute|
      @tufts_pdf.send("#{attribute}=", send(attribute))
    end
  end
  public
  attr_accessor *attributes
end
