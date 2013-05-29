class GenericsController < ApplicationController
  before_filter :load_object, only: [:edit, :update]
  def edit
    authorize! :edit, @generic
  end


  def update
    authorize! :update, @generic
    @generic.update_attributes(params[:generic])
    @generic.save(validate: false)
    redirect_to hydra_editor.edit_record_path(@generic)
  end

  private

  def load_object
    @generic = ActiveFedora::Base.find(params[:id], cast: true)
  end
end
