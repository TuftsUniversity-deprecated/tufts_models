module DraftVersion
  extend ActiveSupport::Concern

  included do

    def self.build_draft_version(attrs = {})
      attrs.merge!(pid: PidUtils.to_draft(attrs[:pid])) if attrs[:pid]
      attrs.merge!(namespace: PidUtils.draft_namespace)
      new(attrs)
    end

    def self.draft_pid(pid)
      "#{draft_namespace}:#{stripped_pid(pid)}"
    end

    def self.stripped_pid(pid)
      pid.sub(/.+:(.+)$/, '\1')
    end

    # Publish the record to the production fedora server
    def publish!(user_id = nil)
      self.working_user = User.where(id: user_id).first
      self.admin.published_at = self.edited_at = DateTime.now

      create_published_version!
    end

    private
    def create_published_version!
      published_pid = PidUtils.to_published(pid)

      if self.class.exists?(published_pid)
        self.class.destroy(published_pid)
      end

      published_obj = self.class.new(attributes.except("id").merge(pid: published_pid))

      if published_obj.save
        now = DateTime.now
        published_obj.update_attributes(published_at: now, edited_at: now)
        # Avoid before_save bookkeeping in base_model. There's got to be a better way to do this.
        if save(run_callbacks: false)
          update_attributes(published_at: now, edited_at: now)
        end

        audit(working_user, 'Pushed to production')
      else
        raise "Unable to publish object, #{published_obj.errors.inspect}"
      end
    end

    #def push_to_production!
    #  if save
    #    self.audit(working_user, 'Pushed to production')
    #    # Now copy to prod
    #    # Rubydora::FedoraInvalidRequest
    #    foxml = self.inner_object.repository.api.export(pid: pid, context: 'archive')
    #    # You can't ingest to a pid that already exists, so try to purge it first
    #    production_fedora_connection.purge_object(pid: pid) rescue RestClient::ResourceNotFound
    #    production_fedora_connection.ingest(file: foxml)
    #  else
    #    # couldn't save
    #    raise "Unable to push to production"
    #  end

    #end

  end  # end "included" section


  #    def draft?
  #      # Handle case where pid isn't set yet?
  #      pid.start_with?(self.class.draft_namespace)
  #    end

  #    def draft_pid
  #      self.class.draft_pid(pid)
  #    end

  #    def production_pid
  #      self.class.production_pid(pid)
  #    end

end
