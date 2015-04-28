class UnpublishService < WorkflowService

  def initialize(object, user_id = nil)
    draft = object.draft? ? object : object.find_draft
    super(draft, user_id)
  end

  def run
    destroy_published_version!
    object.unpublishing = true
    object.update_attributes(published_at: nil)
    object.unpublishing = false
    audit('Unpublished')
  end

end
