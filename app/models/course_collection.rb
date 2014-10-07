class CourseCollection < CuratedCollection
  include WithNestedMembers
  include CreatedByTdil

  after_create :add_to_root_collection

  def add_to_root_collection
    return if root?
    CourseCollection.root.tap do |root|
      root.member_ids = [id] + root.member_ids
      root.save!
    end
  end

  # Sets the default value for the edit form.
  def type
    'course'
  end

  def creator
    super.first
  end

  ROOT_PID = 'tufts:root_collection'

  def root?
    self.pid == ROOT_PID
  end

  class << self
    def root
      root = CourseCollection.where(id: ROOT_PID).first
      root ||= CourseCollection.create!(pid: ROOT_PID, title: 'Root')
    end
  end

end
