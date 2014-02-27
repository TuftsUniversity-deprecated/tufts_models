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
      if ActiveFedora::Base.exists?(args[:pid])
        flash[:alert] = "A record with the pid \"#{args[:pid]}\" already exists."
        redirect_to hydra_editor.edit_record_path(args[:pid])
      else
        @record = params[:type].constantize.new(args)
        @record.save(validate: false)
        redirect_to next_page
      end
    else
      flash[:error] = "You have specified an invalid pid. A valid pid must contain a colon (i.e. tufts:1231)"
      render 'choose_type'
    end
  end

  def publish
    @record = ActiveFedora::Base.find(params[:id], cast: true)
    authorize! :publish, @record
    @record.audit(current_user, 'pushed to production')
    @record.push_to_production!
    redirect_to catalog_path(@record), notice: "\"#{@record.title}\" has been pushed to production"
  end

  def destroy
    authorize! :destroy, @record
    @record.state= "D"
    @record.save(validate: false)
    # only push to production if it's already on production.
    @record.audit(current_user, 'deleted')
    @record.push_to_production! if @record.published_at
    flash[:notice] = "\"#{@record.title}\" has been purged"
    redirect_to root_path
  end

  def cancel
    if @record.DCA_META.versions.empty?
      authorize! :destroy, @record
      @record.destroy
    end
    redirect_to root_path
  end

  def set_attributes
    @record.working_user = current_user
    # set rightsMetadata access controls
    @record.apply_depositor_metadata(current_user)
    super
  end

  private

  def load_object
    @record = ActiveFedora::Base.find(params[:id], cast: true)
  end

  def next_page
    if @record.is_a?(TuftsTemplate)
      hydra_editor.edit_record_path(@record)
    else
      record_attachments_path(@record)
    end
  end

end
