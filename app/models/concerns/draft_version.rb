module DraftVersion
  extend ActiveSupport::Concern

  included do

    def self.draft_namespace
      'draft'
    end

    def self.production_namespace
      'tufts'
    end

    def self.build_draft_version(attrs = {})
      attrs.merge!(pid: draft_pid(attrs[:pid])) if attrs[:pid]
      attrs.merge!(namespace: draft_namespace)
      new(attrs)
    end

    def self.draft_pid(pid)
      "#{draft_namespace}:#{stripped_pid(pid)}"
    end

    def self.stripped_pid(pid)
      pid.sub(/.+:(.+)$/, '\1')
    end

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
