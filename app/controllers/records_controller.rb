class RecordsController < ApplicationController
  include RecordsControllerBehavior

  before_filter :load_object, only: [:review, :publish, :destroy, :cancel]
  authorize_resource only: [:review]

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

  def review
    if @record.respond_to?(:reviewed)
      @record.reviewed
      if @record.save
        flash[:notice] = "\"#{@record.title}\" has been marked as reviewed."
      else
        flash[:error] = "Unable to mark \"#{@record.title}\" as reviewed."
      end

    else
      flash[:error] = "Unable to mark \"#{@record.title}\" as reviewed."
    end
    redirect_to catalog_path(@record)
  end

  def publish
    authorize! :publish, @record
    @record.publish!(current_user.id)
    redirect_to catalog_path(@record), notice: "\"#{@record.title}\" has been pushed to production"
  end

  def destroy
    authorize! :destroy, @record
    @record.state= "D"
    @record.save(validate: false)
    # only push to production if it's already on production.
    @record.audit(current_user, 'deleted')
    @record.push_to_production! if @record.published_at
    if @record.is_a?(TuftsTemplate)
      flash[:notice] = "\"#{@record.template_name}\" has been purged"
      redirect_to templates_path
    else
      flash[:notice] = "\"#{@record.title}\" has been purged"
      redirect_to root_path
    end
  end

  def cancel
    if @record.DCA_META.versions.empty?
      authorize! :destroy, @record
      @record.destroy
    end
    if @record.is_a?(TuftsTemplate)
      redirect_to templates_path
    else
      redirect_to root_path
    end
  end

  def redirect_after_update
    if @record.is_a?(TuftsTemplate)
      templates_path
    else
      main_app.catalog_path @record
    end
  end

  def set_attributes
    @record.working_user = current_user
    # set rightsMetadata access controls
    @record.apply_depositor_metadata(current_user)

    # pull out because it's not a real attribute (it's derived, but still updatable)
    @record.stored_collection_id = params[ActiveModel::Naming.singular(@record)].delete(:stored_collection_id).try(&:first)

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

  # Override method from hydra-editor to include rels-ext fields
  def set_attributes
    rels_ext_fields = { relationship_attributes: params[ActiveModel::Naming.singular(resource)]['relationship_attributes'] }
    resource.attributes = collect_form_attributes.merge(rels_ext_fields)
  end

end
