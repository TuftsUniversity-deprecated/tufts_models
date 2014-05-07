module RecordsHelper
  include RecordsHelperBehavior

  # This method controls the title that appears on the
  # edit page for an object.
  # If the object is a template, override the title that would
  # normally come from hydra-editor and display the
  # template_name instead.
  def render_record_title
    if @record.respond_to?(:template_name)
      @record.template_name
    else
      super
    end
  end

  def sorted_object_types
    object_type_options.to_a.sort{|a,b| a.first <=> b.first }
  end

  # rels-ext selection options for the form to edit a record
  def relationship_options(record)
    record.rels_ext_edit_fields.inject({}) do |options, method_name|
      human_name = method_name.to_s.titleize
      options[human_name] = method_name.to_s
      options
    end
  end

  def relationship_fields(form, record)
    elements = blank_relationship_field(form, record) +
               existing_relationship_fields(form, record)
    content_tag :div, elements, class: 'control-group'
  end

  def blank_relationship_field(form, record)
    content_tag :div, id: 'additional_relationship_attributes_clone' do
      fields_for_one_relationship(form, record)
    end
  end

  def existing_relationship_fields(form, record)
    content_tag :div, id: 'additional_relationship_attributes_elements' do
      record.relationship_attributes.inject(ActiveSupport::SafeBuffer.new) do |fields, builder|
        fields += fields_for_one_relationship(form, record, builder)
      end
    end
  end

  def fields_for_one_relationship(form, record, builder=nil)
    builder ||= RelationshipBuilder.new

    selector = ''
    text = ''
    fields_for "#{form.object_name}[relationship_attributes][]", builder, index: nil do |fof|
      selector = fof.select :relationship_name,
                 relationship_options(record),
                 { include_blank:  'Select relationship' }
      text = fof.text_field :relationship_value
    end
    button = builder.relationship_value.blank? ? add_field(:relationship_attributes) : subtract_field(:relationship_attributes)

    content_tag :div, class: 'record_relationship_fields'  do
      selector + " " + text + " " + button
    end
  end

end
