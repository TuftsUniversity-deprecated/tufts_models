class BatchesController < ApplicationController
  before_filter :build_batch, only: [:create]
  load_resource only: [:show]
  authorize_resource


  # Note: This method is called 'create', but it actually has a
  # mixture of 'new' and 'create' behavior.
  # The reason is because the catalog index page contains one
  # batch form with several submit buttons for different batch
  # operations.  All the buttons except one should submit to the
  # 'create' action.  The button for BatchTemplateUpdate is the
  # exception; It needs to display the 2nd page of the form.
  # If we have time later, we should consider using a bootstrap
  # modal dialog to display the 2nd page of the form directly on
  # the catalog page.
  def create
    if !@batch.pids.present?
      no_pids_selected
    elsif render_next_page_of_form?
      render_new_or_redirect
    else
      create_and_run_batch
    end
  end

  def show
    @records = ActiveFedora::Base.find(@batch.pids, cast: true)
    @jobs = []
  end


private

  def build_batch
    @batch = Batch.new(params.require(:batch).permit(:template_id, {pids: []}, :type))
  end

  def create_and_run_batch
    @batch.creator = current_user

    if @batch.save
      if @batch.run
        redirect_to batch_path(@batch)
      else
        flash[:error] = "Unable to run batch, please try again later."
        @batch.delete
        @batch = Batch.new @batch.attributes.except('id')
        render_new_or_redirect
      end
    else
      render_new_or_redirect
    end
  end

  def render_new_or_redirect
    if @batch.type == 'BatchTemplateUpdate'
      render :new
    else
      redirect_to (request.referer || root_path)
    end
  end

  def no_pids_selected
    flash[:error] = 'Please select some records to do batch updates.'
    redirect_to (request.referer || root_path)
  end

  def render_next_page_of_form?
    params[:batch_form_page].present? && @batch.type == 'BatchTemplateUpdate' && @batch.template_id.nil?
  end

end
