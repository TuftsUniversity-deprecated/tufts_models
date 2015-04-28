class WorkflowService
  attr_reader :object, :user

  def initialize(object, user_id = nil)
    @object = object
    @user = User.find(user_id) if user_id
  end

  private

  # TODO This is shared by publish, unpublish & purge
  def destroy_published_version!
    object.class.destroy_if_exists PidUtils.to_published(object.pid)
  end
end
