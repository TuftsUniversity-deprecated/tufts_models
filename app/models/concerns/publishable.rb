module Publishable
  extend ActiveSupport::Concern

  STATE_DELETED = 'D'

  def workflow_status
    raise "Production objects don't have a workflow" unless draft?
    if published?
      :published
    elsif published_at.blank?
      :new
    else
      :edited
    end
  end

  def publish!(user_id = nil)
    self.publishing = true
    self.working_user = User.where(id: user_id).first

    create_published_version!
  end

  # Has this record been published yet?
  def published?
    published_at && published_at == edited_at
  end

  def purge!
    production_fedora_connection.purge_object(pid: pid) rescue RestClient::ResourceNotFound
    update_attributes(state: STATE_DELETED) # This is a soft-delete
  end

  def purged?
    state == STATE_DELETED
  end

  def draft?
    PidUtils.draft?(pid) || draft_namespace?
  end

  def find_draft
    self.class.find(PidUtils.to_draft(pid))
  end

  def find_published
    self.class.find(PidUtils.to_published(pid))
  end

  private
  # TODO remove this
  def production_fedora_connection
    @prod_repo ||= Rubydora.connect(ActiveFedora.data_production_credentials)
  end

  def create_published_version!
    published_pid = PidUtils.to_published(pid)

    if self.class.exists?(published_pid)
      self.class.find(published_pid).destroy
    end

    published_obj = self.class.new(attributes.except("id").merge(pid: published_pid))

    if published_obj.save
      now = DateTime.now
      published_obj.update_attributes(published_at: now, edited_at: now)

      if save
        audit(working_user, 'Pushed to production')
      end

      self.publishing = false

    else
      raise "Unable to publish object, #{published_obj.errors.inspect}"
    end
  end

  def draft_namespace?
    inner_object && inner_object.respond_to?(:namespace) && inner_object.namespace == PidUtils.draft_namespace
  end

  module ClassMethods
    def revert_to_production(pid)
      prod = Rubydora.connect(ActiveFedora.data_production_credentials)
      begin
        foxml = prod.api.export(pid: pid, context: 'archive')
      rescue RestClient::ResourceNotFound
        raise ActiveFedora::ObjectNotFoundError.new("Could not find pid #{pid} on production server")
      end
      connection_for_pid(pid).purge_object(pid: pid) rescue RestClient::ResourceNotFound
      connection_for_pid(pid).ingest(file: foxml)
    end

    def build_draft_version(attrs = {})
      attrs.merge!(pid: PidUtils.to_draft(attrs[:pid])) if attrs[:pid]
      attrs.merge!(namespace: PidUtils.draft_namespace)
      new(attrs)
    end

  end

end
