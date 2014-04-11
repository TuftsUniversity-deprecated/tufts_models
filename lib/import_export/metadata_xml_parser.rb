class MetadataXmlParserError < StandardError
  def initialize(line)
    @line = line
    super(message)
  end
end
class HasModelNodeNotFoundError < MetadataXmlParserError
  def message
    "Could not find <rel:hasModel> node for object at line #{@line}"
  end
end

module MetadataXmlParser
  class << self
    def file_valid?(file)
      records = parse_file(file)
      # returns an array of human readable errors
    end

    def parse_file(file)
      doc = Nokogiri::XML(File.open(file))
      #TODO collect exceptions as we're looping through digitalObjects
      doc.xpath('//digitalObject').map do |digital_object|
        get_record_attributes(digital_object) << digital_object.line
      end
    end

    def get_namespaces(datastream_class)
      namespaces = datastream_class.ox_namespaces.reduce({}) do |result, pair|
        k,v = pair
        result[k.gsub('xmlns:', '')] = v unless k == 'xmlns'
        result
      end

      # Hacks to fix potential bug in datastream definitions.
      # See: https://github.com/curationexperts/tufts/issues/227#preview_bucket_339
      if datastream_class == TuftsDcaMeta
        namespaces['dcadesc'] ||= namespaces['dcadec']
      end
      if datastream_class == TuftsDcDetailed
        namespaces['dcadesc'] ||= namespaces['dcadec']
        namespaces['dcterms'] = namespaces['dcterms'].gsub("http://purl.org/d/terms/", "http://purl.org/dc/terms/")
      end

      namespaces
    end

    def get_record_attributes(node)
      klass = get_record_class(node)

      attributes = klass.defined_attributes.reduce({}) do |result, attribute|
        attribute_name, definition = attribute
        datastream_class = klass.datastream_class_for_name(definition[:dsid])
        namespaces = get_namespaces(datastream_class)

        #TODO add a test for stored_collection_id; are we going to have rels_ext attributes?

        # query the node for this attribute
        xpath = "." + datastream_class.new.public_send(attribute_name).xpath
        content = node.xpath(xpath, namespaces).map(&:content)

        if content.empty?
          result
        elsif klass.multiple?(attribute_name)
          result.merge(attribute_name => content)
        else
          result.merge(attribute_name => content.first)
        end
      end
      [klass, attributes]
    end

    def get_record_class(node)
      has_model_node = node.at_xpath("//rel:hasModel", {"rel" => "info:fedora/fedora-system:def/relations-external#"})
      raise HasModelNodeNotFoundError.new(node.line) unless has_model_node.present?
      ActiveFedora::Model.from_class_uri(has_model_node.content)
    end
  end
end
