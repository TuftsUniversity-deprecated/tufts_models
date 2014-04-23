require 'import_export/metadata_xml_parser'

class BatchesController < ApplicationController
  before_filter :build_batch, only: [:create]
  load_resource only: [:index, :show, :edit]
  before_filter :load_batch, only: [:update]
  authorize_resource

  def index
    @batches = @batches.order(created_at: :desc)
  end

  def new_template_import
    @batch = BatchTemplateImport.new
  end

  def new_xml_import
    @batch = BatchXmlImport.new
  end

  def create
    case params['batch']['type']
    when 'BatchPublish'
      require_pids_and_run_batch
    when 'BatchPurge'
      require_pids_and_run_batch
    when 'BatchTemplateUpdate'
      handle_apply_template
    when 'BatchTemplateImport'
      handle_import(:new_template_import)
    when 'BatchXmlImport'
      handle_import(:new_xml_import)
    else
      flash[:error] = 'Unable to handle batch request.'
      redirect_to (request.referer || root_path)
    end
  end

  def show
    @records_by_pid = {}
    if @batch.pids
      @records_by_pid = ActiveFedora::Base.find(@batch.pids, cast: true).reduce({}) do |acc, record|
        acc.merge(record.id => record)
      end
    end
  end

  def edit
    if @batch.metadata_file.present?
      pids_in_file = MetadataXmlParser.get_pids(@batch.metadata_file.read)
      @pids_that_already_exist = pids_in_file.select {|pid| ActiveFedora::Base.exists?(pid)}
    end
  end

  def update
    case @batch.type
    when 'BatchTemplateImport'
      handle_update_for_template_import
   when 'BatchXmlImport'
     handle_update_for_xml_import
    else
      flash[:error] = 'Unable to handle batch request.'
      redirect_to (request.referer || root_path)
    end
  end


private

  def build_batch
    @batch = Batch.new(params.require(:batch).permit(:template_id, {pids: []}, :type, :record_type, :metadata_file, :behavior))
  end

  def load_batch
    @batch = Batch.find(params.require(:id))
  end

  def create_and_run_batch
    @batch.creator = current_user

    if @batch.save
      if @batch.run
        redirect_to batch_path(@batch)
      else
        flash[:error] = "Unable to run batch, please try again later."
        @batch.delete
        @batch = Batch.new @batch.attributes.except('id')
        render_new_or_redirect
      end
    else
      render_new_or_redirect  # form errors
    end
  end

  def render_new_or_redirect
    if @batch.type == 'BatchTemplateUpdate'
      render :new
    else
      redirect_to (request.referer || root_path)
    end
  end

  def no_pids_selected
    flash[:error] = 'Please select some records to do batch updates.'
    redirect_to (request.referer || root_path)
  end

  def require_pids_and_run_batch
    if !@batch.pids.present?
      no_pids_selected
    else
      create_and_run_batch
    end
  end

  def handle_apply_template
    if !@batch.pids.present?
      no_pids_selected
    elsif params[:batch_form_page] == '1' && @batch.template_id.nil?
      render :new
    else
      create_and_run_batch
    end
  end

  def handle_import(form_view)
    @batch.creator = current_user

    if @batch.save
      redirect_to edit_batch_path(@batch)
    else
      render form_view
    end
  end

  def collect_warning(record, doc)
    dsid = record.class.original_file_datastreams.first
    if !record.valid_type_for_datastream?(dsid, doc.content_type)
      "You provided a #{doc.content_type} file, which is not a valid type: #{doc.original_filename}"
    end
  end

  def collect_errors(batch, records)
    (batch.errors.full_messages + records.map{|r| r.errors.full_messages }.flatten).compact
  end

  # TODO: Take a look at the handle_update_for_template_import method, handle_update_for_xml_import method and attachments_controller update method, and see if we can pull out any common code.

  def handle_update_for_xml_import
    if params[:documents].blank?
      # no documents have been passed in
      flash[:error] = "Please select some files to upload."
      render :edit
    else

      document_statuses = params[:documents].map do |doc|
        record, warning, error = nil, nil, nil
        if @batch.uploaded_files.keys.include? doc.original_filename
          [doc, record, warning, "#{doc.original_filename} has already been uploaded"]
        else
          begin
            record = MetadataXmlParser.build_record(@batch.metadata_file.read, doc.original_filename)
            record.batch_id = @batch.id.to_s
            saved = save_record_with_document(record, doc)
            warning = collect_warning(record, doc)
            if saved
              @batch.uploaded_files[doc.original_filename] = record.pid
            end
          rescue MetadataXmlParserError => e
            error = e.message
          end
          [doc, record, warning, error]
        end
      end
      docs, records, warnings, errors = document_statuses.transpose

      successful = @batch.save &&  # our batch saved
        errors.compact.empty? &&   # we have no errors from building records
        records.all?(&:persisted?) # all our records saved

      respond_to_import(successful, @batch, document_statuses)
    end
  end

  #TODO add transaction around batch. Is this needed?
  #TODO add transaction around everything? Is this possible?
  def handle_update_for_template_import
    if params[:documents].blank?
      # no documents have been passed in
      flash[:error] = "Please select some files to upload."
      render :edit
    else
      attrs = @batch.template.attributes_to_update.merge(batch_id: @batch.id.to_s)
      record_class = @batch.record_type.constantize

      document_statuses = params[:documents].map do |doc|
        record = record_class.new(attrs)
        save_record_with_document(record, doc)
        [doc, record, collect_warning(record, doc), nil]
      end
      docs, records, warnings, errors = document_statuses.transpose

      @batch.pids = (@batch.pids || []) + records.compact.map(&:pid)
      successful = @batch.save &&  # our batch saved
        errors.compact.empty? &&   # we have no errors from building records
        records.all?(&:persisted?) # all our records saved

      respond_to_import(successful, @batch, document_statuses)
    end
  end

  def save_record_with_document(record, doc)
    dsid = record.class.original_file_datastreams.first
    record.working_user = current_user
    if record.save
      record.store_archival_file(dsid, doc)
      record.save
    else
      false
    end
  end

  def respond_to_import(successful, batch, document_statuses)
    docs, records, warnings, errors = document_statuses.transpose.map(&:compact)
    respond_to do |format|
      format.html do
        flash[:alert] = (warnings + errors).join(', ')
        if successful
          redirect_to batch_path(@batch)
        else
          render :edit
        end
      end

      format.json do
        if successful
          redirect_to catalog_path(records.first.id, 'json_format' => 'jquery-file-uploader')
        else
          json = {
            files: document_statuses.map do |doc, record, warning, error|
              msg = {}
              msg[:pid] = record.id if record.present?
              msg[:name] = (record.present? ? record.title : doc.original_filename)
              msg[:warning] = warning if warning.present?
              msg[:error] = collect_errors(batch, records)
              msg[:error] << error if error.present?
              msg
            end
          }.to_json

          render json: json
        end
      end
    end
  end
end
