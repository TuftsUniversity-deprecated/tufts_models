class CuratedCollectionsController < ApplicationController
  # before_filter :load_object, only: [:append_to]
  load_and_authorize_resource only: [:show, :append_to]

  def create
    @curated_collection = CuratedCollection.new(params.require(:curated_collection).permit(:title))
    @curated_collection.displays = ['tdil']
    if @curated_collection.save
      redirect_to (params[:return_url] || root_path)
    else
      render :new
    end
  end

  def show
  end

  def append_to
    render json: {status: "Need to add pid #{params[:pid]} to #{@curated_collection.title} collection (#{@curated_collection.pid})"}
  end

  private

  def load_object
    @curated_collection = CuratedCollection.find(params[:id])
  end
end
