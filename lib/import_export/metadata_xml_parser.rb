class MetadataXmlParserError < StandardError
  def initialize(line=nil, details={})
    @line = line
    @details = details
    super(message)
  end

  def append_details
    @details.empty? ? "" : " (" + @details.map{|k,v| "#{k}: #{v}"}.join(", ") + ")"
  end
end

class NodeNotFoundError < MetadataXmlParserError
  def initialize(line, element, details={})
    @element = element
    super(line, details)
  end

  def message
    "Could not find #{@element} attribute for record beginning at line #{@line}" + append_details
  end
end

class HasModelNodeInvalidError < MetadataXmlParserError
  def initialize(line, message, details={})
    @msg = message
    super(line, details)
  end

  def message
    "Invalid data in <rel:hasModel> for record beginning at line #{@line}." + @msg + append_details
  end
end

class ExistingPidError < MetadataXmlParserError
  def message
    "The PID for the record beginning at line #{@line} already exists in the repository" + append_details
  end
end

class DuplicateFilenameError < MetadataXmlParserError
  def message
    "Duplicate filename found at line #{@line}" + append_details
  end
end

class DuplicatePidError < MetadataXmlParserError
  def message
    "Multiple PIDs defined for record beginning at line #{@line}" + append_details
  end
end

class InvalidPidError < MetadataXmlParserError
  def message
    "Invalid PID defined for record beginning at line #{@line}. Pids must be in this format: tufts:1231" + append_details
  end
end

class ModelValidationError < MetadataXmlParserError
  def initialize(line, error_message, details={})
    @error_message = error_message
    super(line, details)
  end

  def message
    "#{@error_message} for record beginning at line #{@line}" + append_details
  end
end

class FileNotFoundError < MetadataXmlParserError
  def initialize(filename, details={})
    @filename = filename
    super(details)
  end

  def message
    "#{@filename} doesn't exist in the metadata file" + append_details
  end
end

module MetadataXmlParser
  class << self
    def validate(xml)
      doc = Nokogiri::XML(xml)
      errors = doc.errors

      # check for duplicate filenames
      files = doc.xpath("//digitalObject/file/text()")
      files.group_by(&:content).values.map{|nodes| nodes.drop(1)}.flatten.each do |duplicate|
        errors << DuplicateFilenameError.new(duplicate.line, error_details(duplicate))
      end

      pids = doc.xpath("//digitalObject/pid/text()")
      # check for duplicate pids
      pids.group_by(&:content).values.map{|nodes| nodes.drop(1)}.flatten.each do |duplicate|
        errors << DuplicatePidError.new(duplicate.line, error_details(duplicate))
      end
      # check for invalid pids
      pids.reject{|pid| TuftsBase.valid_pid?(pid.content)}.each do |invalid|
        errors << InvalidPidError.new(invalid.line, error_details(invalid))
      end

      doc.xpath('//digitalObject').map do |digital_object|
        if get_node_content(digital_object, "./file").nil?
          errors << NodeNotFoundError.new(digital_object.line, '<file>', error_details(digital_object))
        end
        begin
          record_class = valid_record_class(digital_object)
          m = record_class.new(record_attributes(digital_object, record_class))
          m.valid?
          m.errors.full_messages.each do |message|
            errors << ModelValidationError.new(digital_object.line, message, error_details(digital_object))
          end
        rescue MetadataXmlParserError => e
          errors << e
        end
      end
      errors
    end

    def error_details(node)
      record = node.at_xpath('ancestor-or-self::digitalObject')
      details = {}
      details[:file] = record.at_xpath('file').content if record.at_xpath('file').present?
      details[:pid] = record.at_xpath('pid').content if record.at_xpath('pid').present?
      details
    end

    def build_record(metadata, document_filename)
      doc = Nokogiri::XML(metadata)
      node = doc.at_xpath("//digitalObject[child::file/text()='#{document_filename}']")
      raise FileNotFoundError.new(document_filename) if node.nil?

      record_class = valid_record_class(node)
      attrs = record_attributes(node, record_class)

      if record_class.respond_to?(:build_draft_version)
        record_class.build_draft_version(attrs)
      else
        raise "#{record_class} doesn't implement build_draft_version"
        record_class.new(attrs)
      end
    end

    def get_filenames(xml)
      Nokogiri::XML(xml).xpath('//digitalObject/file').map(&:content)
    end

    def get_pids(xml)
      Nokogiri::XML(xml).xpath('//digitalObject/pid').map(&:content)
    end

    def get_namespaces(datastream_class)
      namespaces = datastream_class.ox_namespaces.reduce({}) do |result, pair|
        k,v = pair
        result[k.gsub('xmlns:', '')] = v unless k == 'xmlns'
        result
      end

      # Hack to fix potential bug in datastream definitions.
      # See https://github.com/curationexperts/mira/issues/227#issuecomment-40148086
      # and https://github.com/curationexperts/tufts_models/issues/11
      if datastream_class == TuftsDcDetailed
        namespaces['dcterms'] = namespaces['dcterms'].gsub("http://purl.org/d/terms/", "http://purl.org/dc/terms/")
      end

      namespaces
    end

    def get_attribute_path(record_class, attribute_name)
      ds_class = record_class.defined_attributes[attribute_name].datastream_class
      {namespaces: get_namespaces(ds_class),
        xpath: ds_class.new.public_send(attribute_name).xpath}
    end

    def record_attributes(node, record_class)
      pid = get_node_content(node, "./pid")
      result = pid.present? ? {:pid => pid} : {}
      # remove attributes that are relationships
      attribute_definitions = record_class.defined_attributes.select do |name, definition|
        definition.dsid != "RELS-EXT"
      end
      attributes = attribute_definitions.reduce(result) do |result, attribute|
        attribute_name, definition = attribute

        path_info = get_attribute_path(record_class, attribute_name)
        namespaces = path_info[:namespaces]
        xpath = "." + path_info[:xpath]

        # query the node for this attribute
        content = get_node_content(node, xpath, namespaces, record_class.multiple?(attribute_name))

        content.blank? ? result : result.merge(attribute_name => content)
      end
      attributes.merge(get_rels_ext(node))
    end

    def get_node_content(node, xpath, namespaces={}, multiple=false)
      content = node.xpath(xpath, namespaces).map(&:content)
      multiple ? content : content.first
    end

    def get_pid(node)
      pid = get_node_content(node, "./pid")
      if pid
        draft_pid = PidUtils.to_draft(pid)
        raise ExistingPidError.new(node.line, error_details(node)) if ActiveFedora::Base.exists?(pid) || ActiveFedora::Base.exists?(draft_pid)
      end
      pid
    end

    def get_file(node)
      filename = get_node_content(node, "./file")
      raise NodeNotFoundError.new(node.line, '<file>', error_details(node)) unless filename
      filename
    end

    def valid_record_class(node)
      class_uri = get_node_content(node, "./rel:hasModel", "rel" => "info:fedora/fedora-system:def/relations-external#")
      raise NodeNotFoundError.new(node.line, '<rel:hasModel>', error_details(node)) unless class_uri
      record_class = ActiveFedora::Model.from_class_uri(class_uri)
      raise HasModelNodeInvalidError.new(node.line, "'#{record_class}' was not amongst the allowed types: #{valid_record_types.inspect}.", error_details(node) ) unless valid_record_types.include?(record_class.to_s)
      record_class
    end

    def valid_record_types
      HydraEditor.models - ['TuftsTemplate']
    end

    def get_rels_ext(node)
      rels_ext = node.xpath("./rel:*", {"rel" => "info:fedora/fedora-system:def/relations-external#"}).map do |element|
        { 'relationship_name' => element.name.underscore.to_sym,
          'relationship_value' => element.content }
      end
      { 'relationship_attributes' => rels_ext }
    end
  end
end
