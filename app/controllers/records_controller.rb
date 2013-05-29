class RecordsController < ApplicationController
  include RecordsControllerBehavior

  before_filter :load_object, only: [:publish, :destroy, :cancel]

  def new
    authorize! :create, ActiveFedora::Base
    unless has_valid_type?
      render 'choose_type'
      return
    end

    args = params[:pid].present? ? {pid: params[:pid]} : {}

    if !args[:pid] || (args[:pid] && /:/.match(args[:pid]))
      @record = params[:type].constantize.new(args)
      @record.save(validate: false)
      redirect_to record_attachments_path(@record)
    else
      flash[:error] = "You have specified an invalid pid. A valid pid must contain a colin (i.e. tufts:1231)"
      render 'choose_type'
    end
  end

  def publish
    @record = ActiveFedora::Base.find(params[:id], cast: true)
    authorize! :publish, @record
    @record.push_to_production!
    redirect_to catalog_path(@record), notice: "\"#{@record.title}\" has been pushed to production"
  end

  def destroy
    authorize! :destroy, @record
    @record.destroy
    redirect_to root_path
  end

  def cancel
    authorize! :destroy, @record
    if @record.DCA_META.versions.empty?
      destroy
    else
      redirect_to root_path
    end
  end

  private

  def load_object
    @record = ActiveFedora::Base.find(params[:id], cast: true)
  end

end
