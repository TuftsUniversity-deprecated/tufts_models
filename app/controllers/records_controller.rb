class RecordsController < ApplicationController
  include RecordsControllerBehavior

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
      initialize_fields
    else
      flash[:error] = "You have specified an invalid pid. A valid pid must contain a colin (i.e. tufts:1231)"
      render 'choose_type'
    end
  end

  def publish
    @record = ActiveFedora::Base.find(params[:id], cast: true)
    authorize! :publish, @record
    @record.push_to_production!
    redirect_to catalog_path(@record), notice: "\"#{@record.title.first}\" has been pushed to production"
  end
  
  def set_attributes
    if params[:files].present?
      # Need to put a fake title on to pass validations in the case that the metadata had never been saved.
      @record.title = 'Temporary title'
      params[:files].each do |dsid, file|
        @record.store_archival_file(dsid, file)
      end
    else
      super
    end
  end

end
