class UnpublishService < WorkflowService

  def initialize(object, user_id = nil)
    super(object.find_draft, user_id)
  end

  def run
    destroy_published_version!
    object.unpublishing = true
    object.update_attributes(published_at: nil)
    object.unpublishing = false
    audit('Unpublished')
  end

end
