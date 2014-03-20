class BatchesController < ApplicationController
  before_filter :build_batch, only: [:new, :create]
  load_resource only: [:show]
  authorize_resource

  def new
    if @batch.pids.present?
    else
      flash[:error] = 'Please select some documents to do batch updates.'
      redirect_to (request.referer || root_path)
    end
  end

  def create
    @batch.creator = current_user
    if @batch.save
      if @batch.run
        redirect_to batch_path(@batch)
      else
        flash[:error] = "Unable to run batch, please try again later."
        @batch.delete
        @batch = Batch.new @batch.attributes.except('id')
        render :new
      end
    else
      render :new
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
end
