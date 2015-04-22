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
    user = User.find(user_id) if user_id
    create_published_version!(user)
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
    draft_pid = pid && pid.start_with?(PidUtils.draft_namespace)
    draft_namespace = inner_object && inner_object.respond_to?(:namespace) && inner_object.namespace == PidUtils.draft_namespace

    draft_pid || draft_namespace
  end

  def find_draft
    self.class.find(PidUtils.to_draft(pid))
  end

  def find_published
    self.class.find(PidUtils.to_published(pid))
  end

  protected

  def published!(user)
    self.publishing = true
    save!
    audit(user, 'Pushed to production')
    self.publishing = false
  end

  private
  # TODO remove this
  def production_fedora_connection
    @prod_repo ||= Rubydora.connect(ActiveFedora.data_production_credentials)
  end

  def create_published_version!(user)
    published_pid = PidUtils.to_published(pid)

    # You can't ingest to a pid that already exists, so try to purge it first
    if self.class.exists?(published_pid)
      self.class.find(published_pid).destroy
    end

    api = inner_object.repository.api
    foxml = api.export(pid: pid, context: 'archive')

    api.ingest(file: foxml.gsub(pid, published_pid))
    published = self.class.find(published_pid)
    published.published!(user)
    published!(user)
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
