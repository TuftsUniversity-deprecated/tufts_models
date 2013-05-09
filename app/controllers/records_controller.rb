class RecordsController < ApplicationController
  include RecordsControllerBehavior

  def new
    authorize! :create, ActiveFedora::Base
    unless has_valid_type?
      render 'choose_type'
      return
    end

    args = params[:pid].present? ? {pid: params[:pid]} : {}
    @record = params[:type].constantize.new(args)
    @record.save!
    initialize_fields
  end

  def publish
    @record = ActiveFedora::Base.find(params[:id], cast: true)
    authorize! :publish, @record
    @record.push_to_production!
    redirect_to catalog_path(@record), notice: "\"#{@record.title.first}\" has been pushed to production"
  end
  
  def set_attributes
    if params[:files].present?
      params[:files].each do |dsid, file|
        @record.store_archival_file(dsid, file)
      end
    else
      super
    end
  end

end
