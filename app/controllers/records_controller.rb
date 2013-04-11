class RecordsController < ApplicationController
  def new
    authorize! :create, ActiveFedora::Base
    unless has_valid_type?
      render 'choose_type'
      return
    end

    @record = params[:type].constantize.new
  end

  def create
    authorize! :create, ActiveFedora::Base
    unless has_valid_type?
      redirect_to new_record_path, :flash=> {error: "Lost the type"}
      return
    end
    record_name = params[:type]
    @record = record_name.constantize.new
    @record.attributes = params[record_name.underscore]
    @record.save!

    redirect_to record_path(@record)
  end

  def show
    authorize! :show, ActiveFedora::Base
    @record = ActiveFedora::Base.find(params[:id], cast: true)
  end

  private

  def has_valid_type?
    # With AF 6.1 we could probably just get AF::Base.decendants
    ["TuftsAudio", "TuftsPdf"].include? params[:type]
  end
end
