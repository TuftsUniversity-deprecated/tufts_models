class UnpublishService < WorkflowService
  def run
    destroy_published_version!
    object.unpublishing = true
    object.update_attributes(published_at: nil)
    object.unpublishing = false
    audit('Unpublished')
  end
end
