module ApplicationHelper

  def li_manage_datastreams_link(document)
    if document.template?
      path = '#'
      klass = 'disabled'
    else
      path = record_attachments_path(document)
      klass = ''
    end

    content_tag :li, :class => klass do
      link_to "Manage Datastreams", path
    end
  end

end
