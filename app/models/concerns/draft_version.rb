module DraftVersion
  extend ActiveSupport::Concern

  included do

    def self.build_draft_version(attrs = {})
      attrs.merge!(pid: PidUtils.to_draft(attrs[:pid])) if attrs[:pid]
      attrs.merge!(namespace: PidUtils.draft_namespace)
      new(attrs)
    end

  end

  def find_draft
    self.class.find(PidUtils.to_draft(pid))
  end

end
