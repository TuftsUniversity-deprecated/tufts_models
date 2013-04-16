module ActiveFedora::Model
  # Takes a Fedora URI for a cModel and returns classname, namespace
  def self.classname_from_uri(uri)
      uri = ModelNameHelper.map_model_name(uri)
      local_path = uri.split('/')[1]
      parts = local_path.split(':')
      return parts[-1].gsub('_', '/').classify, parts[0]
  end
end

