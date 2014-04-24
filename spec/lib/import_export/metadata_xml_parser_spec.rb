require 'spec_helper'
require_relative '../../../lib/import_export/metadata_xml_parser'

describe MetadataXmlParser do
  describe "::validate" do
    it "returns an empty array when there are no errors" do
      expect(MetadataXmlParser.validate(build_node.to_xml)).to eq []
    end

    it "finds ActiveFedora errors for each record" do
      xml = build_node('dc:title' => [], 'admin:displays' => []).to_xml
      errors = MetadataXmlParser.validate(xml).map(&:message)
      expect(errors.sort.first).to match("Displays can't be blank for record beginning at line 1.*")
      expect(errors.sort.second).to match("Title can't be blank for record beginning at line 1.*")
    end

    it "requires valid xml" do
      errors = MetadataXmlParser.validate('<foo></bar').map(&:message)
      expect(errors).to eq ["expected '>'", "Opening and ending tag mismatch: foo line 1 and bar"]
    end

    it "requires a model type (hasModel)" do
      errors = MetadataXmlParser.validate(build_node('rel:hasModel' => []).to_xml).map(&:message)
      expect(errors.first).to match "Could not find <rel:hasModel> .* line 1 .*"
    end

    it "requires a filename" do
      errors = MetadataXmlParser.validate(build_node('file' => []).to_xml).map(&:message)
      expect(errors.first).to match "Could not find <file> .* line 1"
    end

    it "doesn't allow duplicate file names" do
      xml = "<input>" +
        build_node('file' => ['foo.pdf']).to_xml +
        build_node('file' => ['foo.pdf']).to_xml +
        "</input>"
      errors = MetadataXmlParser.validate(xml).map(&:message)
      expect(errors.first).to match /Duplicate filename found at line \d+/
    end
  end

  describe "::build_record" do
    it "builds a record that has the given filename" do
      attributes = {
        'pid' => ['tufts:1'],
        'file' => ['somefile.pdf'],
        'dc:title' => ['some title'],
        'dc:description' => ['desc 1', 'desc 2']
      }
      m = MetadataXmlParser.build_record(build_node(attributes).to_xml, attributes['file'].first)
      expect(m.pid).to eq attributes['pid'].first
      expect(m.title).to eq attributes['dc:title'].first
      expect(m.description).to eq attributes['dc:description']
    end

    context "with a filename that's not in the metadata" do
      it "raises an error" do
        attributes = {
        'file' => ['somefile.pdf'],
        }
        expect{MetadataXmlParser.build_record(build_node(attributes).to_xml, "fail")}.to raise_exception(FileNotFoundError)
      end
    end
  end

  describe "::get_filenames" do
    it "finds all the filenames" do
      xml = "<input>" +
        build_node('file' => ['foo.pdf']).to_xml +
        build_node('file' => ['bar.pdf']).to_xml +
        "</input>"
      expect(MetadataXmlParser.get_filenames(xml)).to eq ['foo.pdf', 'bar.pdf']
    end
  end

  describe "::get_pids" do
    it "finds all the pids" do
      xml = "<input>" +
        build_node('pid' => ['tufts:1']).to_xml +
        build_node('pid' => ['tufts:2']).to_xml +
        "</input>"
      expect(MetadataXmlParser.get_pids(xml)).to eq ['tufts:1', 'tufts:2']
    end
  end

  describe "::get_namespaces" do
    it "converts datastream namespaces to the format Nokogiri wants" do
      ns = MetadataXmlParser.get_namespaces(TuftsDcaMeta)
      expect(ns["dca_dc"]).to eq TuftsDcaMeta.ox_namespaces["xmlns:dca_dc"]
      expect(ns["dcatech"]).to eq TuftsDcaMeta.ox_namespaces["xmlns:dcatech"]
    end

    # if the typos in the namespaces get fixed, we can remove this test and
    # the corresponding code
    it "doesn't modify namespaces if they have been fixed in the project" do
      ns = MetadataXmlParser.get_namespaces(TuftsDcaMeta)
      expect(ns["dcadesc"]).to eq TuftsDcaMeta.ox_namespaces["xmlns:dcadec"]
      ns = MetadataXmlParser.get_namespaces(TuftsDcDetailed)
      expect(ns["dcadesc"]).to eq TuftsDcDetailed.ox_namespaces["xmlns:dcadec"]
      expect(ns["dcterms"]).to eq "http://purl.org/dc/terms/"
    end
  end

  describe "::get_record_attributes" do
    # We're patching ActiveFedora to store the dsid on ActiveFedora::Base#defined attributes.
    # We need this to look up so we know how attributes are stored for each of the defined
    # models. This is used in the xml import stuff in metadata_xml_parser.rb.
    it "should patch ActiveFedora until we upgrade to version 7" do
      # If this test is failing, you can:
      # * remove the ActiveFedora::Attributes::ClassMethods.create_attribute_reader monkeypatch
      # * remove the ActiveFedora::Attributes::ClassMethods.create_attribute_setter monkeypatch
      # * update MetadataXmlParser to use .dsid instead of [:dsid], and
      # * remove this test.
      expect(ActiveFedora::VERSION.split('.').first).to be < 7.to_s
    end

    it "merges in the pid if it exists" do
      attributes = MetadataXmlParser.get_record_attributes(build_node(pid: ['tufts:1']), TuftsPdf)
      expect(attributes[:pid]).to eq 'tufts:1'
    end

    it "sets attributes even if a private method exists with the the attribute's name" do
      attributes = MetadataXmlParser.get_record_attributes(build_node('oxns:format' => ['foo']), TuftsPdf)
      expect(attributes['format']).to eq ['foo']
    end

    it "only returns attributes that were found" do
      attributes = MetadataXmlParser.get_record_attributes(build_node('oxns:format' => []), TuftsPdf)
      expect(attributes.has_key?('format')).to be_false
    end
  end

  describe "::get_node_content" do
    it "gets the content for a multi-value attribute from the given node" do
      d1 = 'Title page printed in red.'
      d2 = 'Several woodcuts signed by the monogrammist "b" appeared first in the Bible of 1490 translated into Italian by Niccol Malermi.'
      namespaces = {"oxns"=>"http://purl.org/dc/elements/1.1/"}
      xpath = ".//oxns:description"
      desc = MetadataXmlParser.get_node_content(build_node, xpath, namespaces, true)
      expect(desc).to eq [d1, d2]
    end

    it "gets the content for a single-value attribute from the given node" do
      expected_title = 'Anatomical tables of the human body.'
      namespaces = {"oxns"=>"http://purl.org/dc/elements/1.1/"}
      xpath = ".//oxns:title"
      title = MetadataXmlParser.get_node_content(build_node, xpath, namespaces)
      expect(title).to eq expected_title
    end
  end

  describe "::get_pid" do
    it "gets the pid" do
      pid = 'tufts:1'
      ActiveFedora::Base.find(pid).destroy if ActiveFedora::Base.exists?(pid)
      pid = MetadataXmlParser.get_pid(node_with_only_pid)
      expect(pid).to eq pid
    end

    it "raises if the pid already exists" do
      pid = 'tufts:1'
      unless ActiveFedora::Base.exists?(pid)
        attrs = FactoryGirl.attributes_for(:tufts_pdf)
        TuftsPdf.create(attrs.merge(pid: pid))
      end
      expect(ActiveFedora::Base.exists?(pid)).to be_true

      expect{
        MetadataXmlParser.get_pid(node_with_only_pid)
      }.to raise_error(InvalidPidError, /A record with this PID already exists for record beginning at line \d+/)
    end
  end

  describe "::get_file" do
    it "gets the filename" do
      expect(MetadataXmlParser.get_file(build_node)).to eq 'anatomicaltables00ches.pdf'
    end

    it "raises if <file> doesn't exist" do
      expect{
        MetadataXmlParser.get_file(node_with_only_pid)
      }.to raise_error(NodeNotFoundError, /Could not find <file> .* line \d+/)
    end
  end

  describe "::get_record_class" do
    it "raises if <hasModel> doesn't exist" do
      expect{
        MetadataXmlParser.get_record_class(node_with_only_pid)
      }.to raise_error(NodeNotFoundError, /Could not find <rel:hasModel> attribute for record beginning at line \d+/)
    end

    it "raises if the given model uri doesn't correspond to a record class" do
      expect{
        MetadataXmlParser.get_record_class(node_with_bad_model)
      }.to raise_error(HasModelNodeInvalidError)
    end

    it "returns a class" do
      record_class = MetadataXmlParser.get_record_class(build_node)
      expect(record_class).to eq TuftsPdf
    end
  end
end

def node_with_only_pid
  doc = Nokogiri::XML(<<-empty_except_pid)
<digitalObject xmlns:rel="info:fedora/fedora-system:def/relations-external#">
  <pid>tufts:1</pid>
</digitalObject>
  empty_except_pid
  node = doc.at_xpath("//digitalObject")
end

def node_with_bad_model
  doc = Nokogiri::XML(<<-bad_model)
<digitalObject xmlns:rel="info:fedora/fedora-system:def/relations-external#">
  <rel:hasModel>info:fedora/cm:Text.SomethingBad</rel:hasModel>
</digitalObject>
  bad_model
  node = doc.at_xpath("//digitalObject")
end

def build_node(overrides={})
  attributes = {
    "pid" => ["tufts:1"],
    "file" => ["anatomicaltables00ches.pdf"],
    "rel:hasModel" => ["info:fedora/cm:Text.PDF"],
    "dc:title" => ["Anatomical tables of the human body."],
    "admin:displays" => ["dl"],
    "dc:description" => ["Title page printed in red.",
                         "Several woodcuts signed by the monogrammist \"b\" appeared first in the Bible of 1490 translated into Italian by Niccol Malermi."],
  }.merge(overrides)

  attribute_xml = attributes.map do |attribute, values|
    values.map do |value|
      "<#{attribute}>#{value}</#{attribute}>"
    end.join("\n")
  end.join("\n")

  Nokogiri::XML('
<digitalObject xmlns:dc="http://purl.org/dc/elements/1.1/"
               xmlns:admin="http://nils.lib.tufts.edu/dcaadmin/"
               xmlns:rel="info:fedora/fedora-system:def/relations-external#"
               xmlns:oxns="http://purl.org/dc/elements/1.1/">
' + attribute_xml + '
</digitalObject>').at_xpath("//digitalObject")
end

