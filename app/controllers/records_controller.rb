class RecordsController < ApplicationController
  include RecordsControllerBehavior

  def publish
    @record = ActiveFedora::Base.find(params[:id], cast: true)
    authorize! :publish, @record
    @record.push_to_production!
    redirect_to catalog_path(@record), notice: "\"#{@record.title.first}\" has been pushed to production"
  end

  protected
  
  # Overridden to have the models we want
  # With AF 6.1 we could probably just do:
  # ActiveFedora::Base.decendants
  def valid_types
    ["TuftsAudio", "TuftsPdf"]
  end
end
