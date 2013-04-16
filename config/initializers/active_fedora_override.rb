module ActiveFedora::Model
  # Takes a Fedora URI for a cModel and returns classname, namespace
  def self.classname_from_uri(uri)
      uri = ModelNameHelper.map_model_name(uri)
      local_path = uri.split('/')[1]
      parts = local_path.split(':')
      return parts[-1].gsub('_', '/').classify, parts[0]
  end
end

# Our foxml fixtures don't have the extension and it seems unnecessary to add them at this point
ActiveFedora::FixtureLoader.class_eval do
    def filename_for_pid(pid)
        File.join(path, "#{pid.gsub(":", "_")}")
    end
end

