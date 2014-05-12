module BlacklightHelper
  include Hydra::BlacklightHelperBehavior

  # This method controls the name of the link for each document
  # that appears on the catalog index page.
  # If the object is a template, override the normal blacklight
  # config and display the template_name_tesim instead.
  def document_show_link_field(document=nil)
    field = if document[:template_name_tesim]
              :template_name_tesim
            else
              super
            end
  end

  # This method controls the title that appears at the top
  # of the show page for an object.
  # If the object is a template, override the normal blacklight
  # config and display the template_name_tesim instead.
  def document_heading(document=nil)
    document ||= @document
    label = document[:template_name_tesim]
    label ||= super
  end

  def render_review_status(solr_doc)
    return nil unless solr_doc.in_a_batch?

    label = content_tag(:dt, 'Review Status:')
    status_box = check_box_tag(:reviewed, :reviewed, solr_doc.reviewed?, type: :checkbox, disabled: true)
    value = content_tag(:dd, status_box)

    label + value
  end

  def fedora_object_state(options)
    state_field = options[:field]
    object_state = options[:document][state_field]
    pretty_object_state(object_state)
  end

  def pretty_object_state(state)
    case state
    when 'A'
      'Active'
    when 'D'
      'Deleted'
    when 'I'
      'Inactive'
    else
      state
    end
  end

end
