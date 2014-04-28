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

  def render_review_status(options={})
    return nil unless options && options[:document]
    return nil unless options[:document].respond_to?(:reviewed?)

    review_status = options[:document].reviewed?
    check_box_tag :reviewed, :reviewed, review_status, type: :checkbox, disabled: true
  end

end
