module BatchesHelper
  def make_dl(title, value, css_class)
    content_tag(:dl, class: "dl-horizontal " + css_class) do
      content_tag(:dt) { title } + 
      content_tag(:dd) { value.to_s }
    end
  end

  def batch_status_text(batch)
    batch.status == :not_available ? 'Status not available' : batch.status.to_s.capitalize
  end

  def job_status_text(batch, job)
    if job.nil?
      if batch.created_at <= Resque::Plugins::Status::Hash.expire_in.ago
        'Status expired'
      else
        'Status not available'
      end
    else
      job.status.capitalize
    end
  end

  def line_item_status(batch, job, record_id=nil)
    if batch.is_a?(BatchTemplateImport) || batch.is_a?(BatchXmlImport)
      record_exists = ActiveFedora::Base.exists?(record_id)
      record_exists ? 'Completed' : 'Status not available'
    else
      job_status_text(@batch, job)
    end
  end

  def item_count(batch)
    if batch.job_ids
      batch.job_ids.count
    elsif batch.pids
      batch.pids.count
    else
      0
    end
  end

end
