class TuftsEAD < TuftsBase

  # Tufts specific needed metadata streams
  # This is unusual, because it's an external datastream, but it is loaded by fedora
  has_metadata :name => "Archival.xml", :type => TuftsEADMeta

  def self.to_class_uri
    'info:fedora/cm:Text.EAD'
  end
end
