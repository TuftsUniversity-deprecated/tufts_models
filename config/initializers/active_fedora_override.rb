module ActiveFedora
  class << self
    attr_writer :data_production_credentials

    def data_production_credentials
      ActiveFedora.config unless @data_production_credentials.present?
      @data_production_credentials
    end
  end
  class Config
    # Override so that we use data_stage as the key rather than the top level
    def init_single(vals)
      ActiveFedora.data_production_credentials = vals.symbolize_keys[:data_production].symbolize_keys
      @credentials = vals.symbolize_keys[:data_stage].symbolize_keys
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

  module Attributes
    module ClassMethods
      # This patch is to store the dsid on the defined attributes. We need this to look up so we know how attributes are stored for this model. This is used in the xml import stuff in metadata_xml_parser.rb.
      def create_attribute_reader_with_dsid_storage(field, dsid, args)
        self.defined_attributes[field] ||= {}
        self.defined_attributes[field][:dsid] = dsid
        create_attribute_reader_without_dsid_storage(field, dsid, args)
      end
      alias_method_chain :create_attribute_reader, :dsid_storage

      def create_attribute_setter_with_dsid_storage(field, dsid, args)
        self.defined_attributes[field] ||= {}
        self.defined_attributes[field][:dsid] = dsid
        create_attribute_setter_without_dsid_storage(field, dsid, args)
      end
      alias_method_chain :create_attribute_setter, :dsid_storage
    end
  end
end
