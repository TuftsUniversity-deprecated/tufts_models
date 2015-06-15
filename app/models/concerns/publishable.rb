module Publishable
  extend ActiveSupport::Concern

  def publishable?
    true
  end

  def workflow_status
    raise "Published objects don't have a workflow" unless draft?
    if published?
      :published
    elsif published_at.blank?
      :new
    else
      :edited
    end
  end

  # Has this record been published yet?
  def published?
    published_at && published_at == edited_at
  end

  def draft?
    PidUtils.draft?(pid) || draft_namespace?
  end

  # TODO this can move into the workflow_service
  def find_draft
    return self if draft?
    self.class.find(PidUtils.to_draft(pid))
  end

  # TODO this can move into the workflow_service
  def find_published
    return self if PidUtils.published?(pid)
    self.class.find(PidUtils.to_published(pid))
  end

  private

  def draft_namespace?
    inner_object && inner_object.respond_to?(:namespace) && PidUtils.draft?(inner_object.namespace)
  end

  module ClassMethods
    def build_draft_version(attrs = {})
      attrs.merge!(pid: PidUtils.to_draft(attrs[:pid])) if attrs[:pid]
      attrs.merge!(namespace: PidUtils.draft_namespace)
      new(attrs)
    end
  end
end
