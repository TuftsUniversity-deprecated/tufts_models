module ApplicationHelper
  def render_files_form(obj)
    if lookup_context.find_all("records/files_form/_#{obj.class.model_name.underscore}").any?
      render :partial => "records/files_form/#{obj.class.model_name.underscore}"
    else 
      render :partial => "records/files_form/default"
    end
  end
end
