class PersonalCollection < CuratedCollection
  include WithNestedMembers
  include CreatedByTdil

  after_create :add_to_root_collection

  attr_accessor :active_user

  def add_to_root_collection
    return unless active_user
    active_user.personal_collection(true).tap do |root|
      root.member_ids = [id] + root.member_ids
      root.save!
    end
  end

  def root?
    parent_count == 0
  end

  # Sets the default value for the edit form.
  def type
    'personal'
  end

  def creator
    super.first
  end
end
