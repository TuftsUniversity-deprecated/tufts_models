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

    def publish!(user_id = nil)
      self.publishing = true
      self.working_user = User.where(id: user_id).first

      create_published_version!
    end

    private
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

  end  # end "included" section


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

end
