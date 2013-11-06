module AttachmentsHelper
  def render_files_form(obj)
    if lookup_context.find_all("attachments/files_form/_#{obj.class.model_name.singular}").any?
      render :partial => "attachments/files_form/#{obj.class.model_name.singular}"
    else 
      render :partial => "attachments/files_form/default"
    end
  end
end
