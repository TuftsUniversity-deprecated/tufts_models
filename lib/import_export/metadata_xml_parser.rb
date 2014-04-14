class MetadataXmlParserError < StandardError
  def initialize(line)
    @line = line
    super(message)
  end
end

class NodeNotFoundError < MetadataXmlParserError
  def initialize(line, element)
    @element = element
    super(line)
  end

  def message
    "Could not find #{@element} node for object at line #{@line}"
  end
end

class HasModelNodeInvalidError < MetadataXmlParserError
  def message
    "Invalid data in <rel:hasModel> for object at line #{@line}"
  end
end

class InvalidPidError < MetadataXmlParserError
  def message
    "A record with this PID already exists for object at line #{@line}"
  end
end

class DuplicateFilenameError < MetadataXmlParserError
  def message
    "Duplicate filename found at line #{@line}"
  end
end

class ModelValidationError < MetadataXmlParserError
  def initialize(line, error_message)
    @error_message = error_message
    super(line)
  end

  def message
    "#{@error_message} for node at line #{@line}"
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
    def validate(xml)
      doc = Nokogiri::XML(xml)
      errors = doc.errors
      files = doc.xpath("//digitalObject/file/text()")
      files.group_by(&:content).values.map{|nodes| nodes.drop(1)}.flatten.each do |duplicate|
        errors << DuplicateFilenameError.new(duplicate.line)
      end
      doc.xpath('//digitalObject').map do |digital_object|
        if get_node_content(digital_object, "./file").nil?
          errors << NodeNotFoundError.new(digital_object.line, '<file>')
        end
        begin
          record_class = get_record_class(digital_object)
          m = record_class.new(get_record_attributes(digital_object, record_class))
          m.valid?
          m.errors.full_messages.each do |message|
            errors << ModelValidationError.new(digital_object.line, message)
          end
        rescue MetadataXmlParserError => e
          errors << e
        end
      end
      errors
    end

    def build_record(metadata, document_filename)
      doc = Nokogiri::XML(metadata)
      node = doc.at_xpath("//digitalObject[child::file/text()='#{document_filename}']")
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
      pid = get_node_content(node, "./pid")
      result = pid.present? ? {:pid => pid} : {}
      record_class.defined_attributes.reduce(result) do |result, attribute|
        attribute_name, definition = attribute
        datastream_class = record_class.datastream_class_for_name(definition[:dsid])
        namespaces = get_namespaces(datastream_class)

        #TODO add a test for stored_collection_id; are we going to have rels_ext attributes?

        # query the node for this attribute
        xpath = "." + datastream_class.new.public_send(attribute_name).xpath
        content = get_node_content(node, xpath, namespaces, record_class.multiple?(attribute_name))

        content.blank? ? result : result.merge(attribute_name => content)
      end
    end

    def get_node_content(node, xpath, namespaces={}, multiple=false)
      content = node.xpath(xpath, namespaces).map(&:content)
      multiple ? content : content.first
    end

    def get_pid(node)
      pid = get_node_content(node, "./pid")
      raise InvalidPidError.new(node.line) if pid && ActiveFedora::Base.exists?(pid)
      pid
    end

    def get_file(node)
      filename = get_node_content(node, "./file")
      raise NodeNotFoundError.new(node.line, '<file>') unless filename
      filename
    end

    def get_record_class(node)
      class_uri = get_node_content(node, "./rel:hasModel", "rel" => "info:fedora/fedora-system:def/relations-external#")
      raise NodeNotFoundError.new(node.line, '<rel:hasModel>') unless class_uri
      record_class = ActiveFedora::Model.from_class_uri(class_uri)
      raise HasModelNodeInvalidError.new(node.line) unless valid_record_types.include?(record_class.to_s)
      record_class
    end

    def valid_record_types
      HydraEditor.models - ['TuftsTemplate']
    end
  end
end
