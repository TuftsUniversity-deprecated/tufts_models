class AttachmentsController < ApplicationController
  def index
    @record = ActiveFedora::Base.find(params[:record_id], cast: true)
    if @record.is_a? TuftsGenericObject
      redirect_to edit_generic_path(@record)
    else
      authorize! :update, @record
    end
  end

  def update
    @record = ActiveFedora::Base.find(params[:record_id], cast: true)
    authorize! :update, @record
    params[:files].each do |dsid, file|
      @record.store_archival_file(dsid, file)
    end
    respond_to do |format|
      if @record.save(validate: false)
        format.html { redirect_to catalog_path(@record), notice: 'Object was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end
end
