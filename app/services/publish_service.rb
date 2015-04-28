class PublishService < WorkflowService
  def initialize(*)
    super
    raise UnpublishableModelError unless object.publishable?
  end

  def run
    published_pid = PidUtils.to_published(object.pid)

    destroy_published_version!
    FedoraObjectCopyService.new(object.class, from: object.pid, to: published_pid).run

    published = object.class.find(published_pid)
    published.published!(user)
    object.published!(user)
  end
end

class UnpublishableModelError < StandardError
  def message
    'Templates cannot be pushed to production'
  end
end

