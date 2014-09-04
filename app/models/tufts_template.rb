class TuftsTemplate < ActiveFedora::Base
  include BaseModel

  has_attributes :template_name, datastream: 'DCA-ADMIN', multiple: false
  validates :template_name, presence: true

  # Initialize and set the default namespace to use when creating templates;
  # If a PID is supplied, the PID namespace will override the default
  # If no PID is supplied, the next sequential PID will be assigned in the default namespace
  # Here templates override fedora's install default and use 'template' as their namespace

  def initialize(attributes = {})
    attributes = {namespace: 'template'}.merge(attributes)
    super
  end

  def self.active
    TuftsTemplate.where('object_state_ssi:A')
  end

  # Templates should never be pushed to the production
  # environment.  They are meant to be used by admin users
  # to ingest files in bulk and apply the same metadata to
  # many files.  There should be no need for them to be
  # visible to general users.

  def publish!(user_id = nil)
    raise UnpublishableModelError.new
  end

  def push_to_production!
    raise UnpublishableModelError.new
  end

  def published?
    false
  end

  def queue_jobs_to_apply_template(user_id, record_ids, batch_id)
    attrs = attributes_to_update
    return if attrs.empty?

    record_ids.map do |id|
      Job::ApplyTemplate.create(user_id: user_id, record_id: id, attributes: attrs, batch_id: batch_id)
    end
  end

  # The list of fields to edit from the DCA_ADMIN datastream
  def admin_display_fields
    super + [:template_name]
  end

  def terms_for_updating
    terms_for_editing - [:template_name]
  end

  def attributes_to_update
    updates = terms_for_updating.inject({}) do |attrs, attribute|
      value_of_attr = self.send(attribute)
      unless attr_empty?(value_of_attr)
        attrs.merge!(attribute => value_of_attr)
      end
      attrs
    end

    rels_ext_attrs = relationship_attributes.map do |attr|
      { 'relationship_name'  => attr.relationship_name,
        'relationship_value' => attr.relationship_value }
    end
    unless rels_ext_attrs.blank?
      updates.merge!(relationship_attributes: rels_ext_attrs)
    end

    updates
  end

  def apply_attributes(*args)
    raise CannotApplyTemplateError.new
  end

private

  def attr_empty?(value)
    Array(value).all?{|x| x.blank? }
  end

end

class CannotApplyTemplateError < StandardError
  def message
    'Templates cannot be updated by templates'
  end
  def to_s
    self.class.to_s + ": " + message
  end
end

class UnpublishableModelError < StandardError
  def message
    'Templates cannot be pushed to production'
  end
end
