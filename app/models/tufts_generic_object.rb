class TuftsGenericObject < TuftsBase
  has_metadata :name => "GENERIC-CONTENT", :type => TuftsGenericMeta

  def self.to_class_uri
    'info:fedora/cm:Object.Generic'
  end

end
