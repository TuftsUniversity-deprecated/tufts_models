module BatchUpdate
  extend ActiveSupport::Concern

  def apply_attributes(attributes, user_id = nil)
    # stored_collection_id is a special case because it's
    # not a defined attribute in active-fedora; it's a
    # derived attribute.
    attrs_for_update = { stored_collection_id: attributes.delete(:stored_collection_id) }

    # For attributes that can have multiple values, we want to
    # add the new value to the existing values, not overwrite
    # the existing values.
    attributes.each do |key, value|
      if self.class.multiple?(key)
        attrs_for_update[key] = (self.send(key) + Array(value)).uniq
      else
        attrs_for_update[key] = value
      end
    end

    self.working_user = User.where(id: user_id).first
    update_attributes(attrs_for_update)
  end

end
