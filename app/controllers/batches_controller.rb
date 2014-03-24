class BatchesController < ApplicationController
  before_filter :build_batch, only: [:create]
  load_resource only: [:show]
  authorize_resource

  def create
    if !@batch.pids.present?
      no_pids_selected
    elsif next?
      render_next_page_of_form
    else
      create_and_run_batch
    end
  end

  def show
    @documents = ActiveFedora::Base.find(@batch.pids, cast: true)
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
        render_or_redirect
      end
    else
      render_or_redirect
    end
  end

  def render_or_redirect
    if @batch.type == 'BatchTemplateUpdate'
      render :new
    else
      redirect_to (request.referer || root_path)
    end
  end

  def no_pids_selected
    flash[:error] = 'Please select some documents to do batch updates.'
    redirect_to (request.referer || root_path)
  end

  def next?
    params[:batch_form_page].present? && @batch.type == 'BatchTemplateUpdate' && @batch.template_id.nil?
  end

  def render_next_page_of_form
    render_or_redirect
  end

end
