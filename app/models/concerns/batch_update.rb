module BatchUpdate
  extend ActiveSupport::Concern

  def apply_attributes(attributes, user_id = nil, overwrite = false)
    self.working_user = User.where(id: user_id).first if user_id

    # stored_collection_id is a special case because it's
    # not a defined attribute in active-fedora; it's a
    # derived attribute.
    collection = attributes.delete(:stored_collection_id)
    can_set_collection = overwrite || stored_collection_id.blank?
    if collection && can_set_collection
      self.stored_collection_id = collection
    end

    attrs_for_update = {}
    attributes.each do |key, value|
      if self.class.multiple?(key)
        new_value = Array(value)
        new_value = self[key] + new_value unless overwrite
        attrs_for_update[key] = new_value.uniq
      else
        if overwrite || self[key].empty?
          attrs_for_update[key] = value
        end
      end
    end
    update_attributes(attrs_for_update)
  end

end
