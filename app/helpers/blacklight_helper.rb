module BlacklightHelper
  include Hydra::BlacklightHelperBehavior

  # This method controls the name of the link for each document
  # that appears on the catalog index page.
  # If the object is a template, override the normal blacklight
  # config and display the template_title_tesim instead.
  def document_show_link_field(document=nil)
    field = if document[:template_title_tesim]
              :template_title_tesim
            else
              super
            end
  end

  # This method controls the title that appears at the top
  # of the show page for an object.
  # If the object is a template, override the normal blacklight
  # config and display the template_title_tesim instead.
  def document_heading(document=nil)
    document ||= @document
    label = document[:template_title_tesim]
    label ||= super
  end

end
