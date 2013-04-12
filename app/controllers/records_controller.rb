class RecordsController < ApplicationController
  def new
    authorize! :create, ActiveFedora::Base
    unless has_valid_type?
      render 'choose_type'
      return
    end

    @record = params[:type].constantize.new
    initialize_fields
  end

  def edit
    @record = ActiveFedora::Base.find(params[:id], cast: true)
    authorize! :edit, @record
    initialize_fields
  end

  def create
    authorize! :create, ActiveFedora::Base
    unless has_valid_type?
      redirect_to new_record_path, :flash=> {error: "Lost the type"}
      return
    end
    @record = params[:type].constantize.new
    @record.attributes = params[@record.class.model_name.underscore]
    @record.save!

    redirect_to catalog_path(@record)
  end

  def update
    @record = ActiveFedora::Base.find(params[:id], cast: true)
    authorize! :update, @record
    @record.attributes = params[@record.class.model_name.underscore]
    @record.save!

    redirect_to catalog_path(@record)
  end

  private

  def has_valid_type?
    # With AF 6.1 we could probably just do:
    # ActiveFedora::Base.decendants.include? params[:type]
    ["TuftsAudio", "TuftsPdf"].include? params[:type]
  end

  def initialize_fields
    @record.terms_for_editing.each do |key|
      # if value is empty, we create an one element array to loop over for output 
      @record[key] = [''] if @record[key].empty?
    end
  end
end
