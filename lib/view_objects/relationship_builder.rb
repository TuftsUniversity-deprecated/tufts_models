# A helper object that is used in the views to build up
# relationships when editing a fedora record.
class RelationshipBuilder
  attr_accessor :relationship_name, :relationship_value

  def initialize(name=nil, value=nil)
    @relationship_name = name
    @relationship_value = value
  end

#  def pretty_name
#    relationship_name.to_s.titleize
#  end

end
