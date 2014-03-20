module RecordsHelper
  include RecordsHelperBehavior

  # This method controls the title that appears on the
  # edit page for an object.
  # If the object is a template, override the title that would
  # normally come from hydra-editor and display the
  # template_name instead.
  def render_record_title
    if @record.respond_to?(:template_name)
      @record.template_name
    else
      super
    end
  end

end
