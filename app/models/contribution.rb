class Contribution
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  

  ATTRIBUTES = [:title, :abstract, :creator, :contributor, :bibliographic_citation, :subject, :attachment, :other_authors, :license]
  attr_accessor *ATTRIBUTES


  validates :title, presence: true, length: {maximum: 250}
  validates :abstract, presence: true, length: {maximum: 2000}
  validates :creator, presence: true
  validates :attachment, presence: true

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

    (ATTRIBUTES - [:attachment, :other_authors]).each do |attribute|
      @tufts_pdf.send("#{attribute}=", send(attribute))
    end
    @tufts_pdf.creator += [other_authors] if other_authors
    @tufts_pdf
  end

  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end

  def save
    return false unless valid?
    tufts_pdf.save!
    tufts_pdf.store_archival_file('Archival.pdf', attachment)
    tufts_pdf.save!
    tufts_pdf
  end

  def self.create(attrs)
    form = self.new(attrs)
    form.save
  end

end
