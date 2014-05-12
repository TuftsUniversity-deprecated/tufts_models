module BatchUpdate
  extend ActiveSupport::Concern

  def apply_attributes(attributes, user_id = nil, overwrite = false)
    self.working_user = User.where(id: user_id).first if user_id

    new_rels_ext = attributes.delete('relationship_attributes') || []
    apply_rels_ext_attributes(new_rels_ext, overwrite)

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

  def apply_rels_ext_attributes(new_rels_ext, overwrite = false)
    existing_rels_ext = relationship_attributes.map do |builder|
      { 'relationship_name'  => builder.relationship_name,
        'relationship_value' => builder.relationship_value }
    end

    if overwrite
      # Remove existing value from the list if there is
      # a new value to replace it
      new_keys = new_rels_ext.map{ |h| h['relationship_name'].to_sym }
      existing_rels_ext.delete_if {|rel| new_keys.include?(rel['relationship_name']) }
    end

    rels_ext_attrs = existing_rels_ext + new_rels_ext

    unless rels_ext_attrs.blank?
      self.relationship_attributes = rels_ext_attrs
    end
  end

end
