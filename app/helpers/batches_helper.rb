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
end
