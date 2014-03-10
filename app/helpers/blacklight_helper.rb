require Blacklight::Engine.root.join('app/helpers/blacklight_helper')

module BlacklightHelper

  def doc_label(document)
    label = Array(document['template_title_tesim']).first
    label ||= document_show_link_field(document)
  end

end
