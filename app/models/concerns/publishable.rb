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

  def unpublish!(user_id = nil)
    destroy_published_version!
    user = User.find(user_id) if user_id
    audit(user, 'Unpublished')
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

  # copy the published object over the draft
  def revert!
    published_pid = PidUtils.to_published(pid)
    draft_pid = PidUtils.to_draft(pid)

    if self.class.exists? published_pid
      destroy_draft_version!
      deep_copy_fedora_object from: published_pid, to: draft_pid
    end
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

  def destroy_published_version!
    self.class.destroy_if_exists PidUtils.to_published(pid)
  end

  def destroy_draft_version!
    self.class.destroy_if_exists PidUtils.to_draft(pid)
  end

  def create_published_version!(user)
    published_pid = PidUtils.to_published(pid)

    destroy_published_version!
    deep_copy_fedora_object from: pid, to: published_pid

    published = self.class.find(published_pid)
    published.published!(user)
    published!(user)
  end

  def deep_copy_fedora_object(options = {})
    source_pid = options.fetch(:from)
    destination_pid = options.fetch(:to)

    return false unless self.class.exists? source_pid

    api = inner_object.repository.api

    foxml = api.export(pid: source_pid, context: 'archive')
    api.ingest(file: foxml.gsub(source_pid, destination_pid))
  end

  def draft_namespace?
    inner_object && inner_object.respond_to?(:namespace) && inner_object.namespace == PidUtils.draft_namespace
  end

  module ClassMethods
    def build_draft_version(attrs = {})
      attrs.merge!(pid: PidUtils.to_draft(attrs[:pid])) if attrs[:pid]
      attrs.merge!(namespace: PidUtils.draft_namespace)
      new(attrs)
    end

    def destroy_if_exists(pid)
      if exists?(pid)
        find(pid).destroy
      end
    end
  end

end
