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

class HasModelNodeInvalidError < MetadataXmlParserError
  def message
    "Invalid data in <rel:hasModel> for object at line #{@line}"
  end
end

# #create
# errors = MetadataXmlParser.validate_file(file)
# flash[:errors] = errors.join('<br/>') if errors.any?

# #update
# begin
# record = MetadataXmlParser.build_record(@batch.metadata_file, params[:file].filename)
# record.datasream.whatever(params[:file])
# record.save
# rescue
#   render json: {errors: e.message}
# end

module MetadataXmlParser
  class << self
    def validate_file(file)
      doc = Nokogiri::XML(File.open(file))
      errors = []
      doc.xpath('//digitalObject').map do |digital_object|
        begin
          record_class = get_record_class(digital_object)
          get_record_attributes(digital_object, record_class)
        rescue MetadataXmlParserError => e
          errors << e
        end
        begin
          get_file(digital_object)
        rescue MetadataXmlParserError => e
          errors << e
        end
      end
      errors
    end

    def build_record(metadata_filename, document_filename)
      doc = Nokogiri::XML(File.open(file))
      node = doc.at_xpath("//digitalObject[file=#{document_filename}]")
      record_class = get_record_class(node)
      record_class.new(get_record_attributes(node, record_class))
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

    def get_record_attributes(node, record_class)
      record_class.defined_attributes.reduce({}) do |result, attribute|
        attribute_name, definition = attribute
        datastream_class = record_class.datastream_class_for_name(definition[:dsid])
        namespaces = get_namespaces(datastream_class)

        #TODO add a test for stored_collection_id; are we going to have rels_ext attributes?

        # query the node for this attribute
        xpath = "." + datastream_class.new.public_send(attribute_name).xpath
        content = get_node_content(node, xpath, namespaces, record_class.multiple?)

        content.blank? ? result : result.merge(attribute_name => content)
      end
    end

    def get_node_content(node, xpath, namespaces={}, multiple=false)
      content = node.xpath(xpath, namespaces).map(&:content)
      multiple ? content : content.first
    end

    def get_pid(node)
      get_node_content(node, "./pid")
    end

    def get_file(node)
      get_node_content(node, "./file")
    end

    def get_record_class(node)
      class_uri = get_node_content(node, "./rel:hasModel", "rel" => "info:fedora/fedora-system:def/relations-external#")
      raise HasModelNodeNotFoundError.new(node.line) unless class_uri
      record_class = ActiveFedora::Model.from_class_uri(class_uri)
      raise HasModelNodeInvalidError.new(node.line) unless valid_record_types.include?(record_class.to_s)
      record_class
    end

    def valid_record_types
      HydraEditor.models - ['TuftsTemplate']
    end
  end
end
