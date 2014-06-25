module ActiveFedora
  class << self
    attr_writer :data_production_credentials

    def data_production_credentials
      ActiveFedora.config unless @data_production_credentials.present?
      @data_production_credentials
    end
  end

  class Config
    # Override so that we use data_stage as the key rather than the top level if this is MIRA.
    def init_single(vals)
      ActiveFedora.data_production_credentials = vals.symbolize_keys[:data_production].symbolize_keys
      fedora_instance = Tufts::Application.mira? ? :data_stage : :data_production
      @credentials = vals.symbolize_keys[fedora_instance].symbolize_keys

      unless @credentials.has_key?(:user) && @credentials.has_key?(:password) && @credentials.has_key?(:url)
        raise ActiveFedora::ConfigurationError, "Fedora configuration must provide :user, :password and :url."
      end
    end
  end

  module Model
    # Takes a Fedora URI for a cModel and returns classname, namespace
    def self.classname_from_uri(uri)
        uri = ModelNameHelper.map_model_name(uri)
        local_path = uri.split('/')[1]
        parts = local_path.split(':')
        return parts[-1].gsub('_', '/').classify, parts[0]
    end
  end
end
