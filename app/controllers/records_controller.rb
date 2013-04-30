class RecordsController < ApplicationController
  include RecordsControllerBehavior

  def publish
    @record = ActiveFedora::Base.find(params[:id], cast: true)
    authorize! :publish, @record
    @record.push_to_production!
    redirect_to catalog_path(@record), notice: "\"#{@record.title.first}\" has been pushed to production"
  end
  
  def set_attributes
    super
    @record.inner_object.pid = params[:pid] if params[:pid]
  end

end
