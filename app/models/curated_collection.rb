class CuratedCollection < TuftsBase
  def initialize(attributes = {})
    attributes = {displays: ['tdil']}.merge(attributes)
    super
  end
end
