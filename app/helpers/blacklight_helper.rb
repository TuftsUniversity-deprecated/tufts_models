module BlacklightHelper
  include Hydra::BlacklightHelperBehavior

  def document_show_link_field(document=nil)
    field = if document[:template_title_tesim]
              :template_title_tesim
            else
              super  # super from blacklight
            end
  end

  def document_heading(document=nil)
    document ||= @document
    label = document[:template_title_tesim]
    label ||= super  # super from blacklight
  end

end
