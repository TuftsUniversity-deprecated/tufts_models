class BatchTemplateImport < Batch
  validates :template_id, presence: true
  validates :record_type, presence: true
  validate  :template_creates_valid_object, if: :template_id?

  def self.valid_record_types
    HydraEditor.models - ['TuftsTemplate']
  end

  def display_name
    'Template Import'
  end

  def template
    TuftsTemplate.find(template_id)
  end

protected

  def template_creates_valid_object
    if BatchTemplateImport.valid_record_types.include?(record_type)
      template = TuftsTemplate.find(template_id)
      record = record_type.constantize.new(template.attributes_to_update)
      return if record.valid?
    end

    errors.add(:base, "The template does not have the required attributes for the selected record type.")
  end

end
