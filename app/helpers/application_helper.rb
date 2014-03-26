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

  def li_review_link(document)
    if document.reviewable?
      path = review_record_path(document)
      klass = ''
      method = :put
    else
      path = '#'
      klass = 'disabled'
      method = :get
    end

    content_tag :li, :class => klass do
      link_to "Mark as Reviewed", path, method: method
    end
  end

end
