require 'spec_helper'
require_relative '../../../lib/import_export/metadata_xml_parser'

describe MetadataXmlParser do
  describe "::validate_file" do
    it "doesn't allow duplicate file names"
    it "finds ActiveFedora errors for each record"
    it "requires a model type (hasModel)"
    it "requires valid xml"
    it "returns an array of human readable error messages"
  end

  describe "::parse_file" do
    it "returns the correct number of records"
    it "returns the record class, attributes and line number for each node"
  end

  describe "::get_namespaces" do
    it "converts datastream namespaces to the format Nokogiri wants"

    # if the typos in the namespaces get fixed, we can remove this test and
    # the corresponding code
    it "doesn't modify namespaces if they have been fixed in the project"
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

    it "merges in the pid if it exists"
    it "returns the record class for a given node"
  end

  describe "::get_node_content" do
    it "gets the content for a multi-value attribute from the given node" do
      d1 = 'Title page printed in red.'
      d2 = 'Several woodcuts signed by the monogrammist "b" appeared first in the Bible of 1490 translated into Italian by Niccol Malermi.'
      namespaces = {"oxns"=>"http://purl.org/dc/elements/1.1/"}
      xpath = ".//oxns:description"
      desc = MetadataXmlParser.get_node_content(pdf_node, xpath, namespaces, true)
      expect(desc).to eq [d1, d2]
    end

    it "gets the content for a single-value attribute from the given node" do
      expected_title = 'Anatomical tables of the human body.'
      namespaces = {"oxns"=>"http://purl.org/dc/elements/1.1/"}
      xpath = ".//oxns:title"
      title = MetadataXmlParser.get_node_content(pdf_node, xpath, namespaces)
      expect(title).to eq expected_title
    end

    it "gets the content for attributes when a private method exists with the attribute's name"
        #TODO TuftsDcaMeta.new.format was a problem, use this as a test case
  end

  describe "::get_pid" do
    it "gets the pid" do
      pid = MetadataXmlParser.get_pid(node_with_only_pid)
      expect(pid).to eq 'tufts:1'
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
      }.to raise_error(InvalidPidError, /A record with this PID already exists for object at line \d+/)
    end
  end

  describe "::get_file" do
    it "gets the filename" do
      expect(MetadataXmlParser.get_file(pdf_node)).to eq 'anatomicaltables00ches.pdf'
    end

    it "raises if <file> doesn't exist" do
      expect{
        MetadataXmlParser.get_file(node_with_only_pid)
      }.to raise_error(NodeNotFoundError, /Could not find <file> node for object at line \d+/)
    end
  end

  describe "::get_record_class" do
    it "raises if <hasModel> doesn't exist" do
      expect{
        MetadataXmlParser.get_record_class(node_with_only_pid)
      }.to raise_error(NodeNotFoundError, /Could not find <rel:hasModel> node for object at line \d+/)
    end

    it "raises if the given model uri doesn't correspond to a record class" do
      expect{
        MetadataXmlParser.get_record_class(node_with_bad_model)
      }.to raise_error(HasModelNodeInvalidError)
    end

    it "returns a class" do
      record_class = MetadataXmlParser.get_record_class(pdf_node)
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

def pdf_node
  doc = Nokogiri::XML(<<-pdf)
<digitalObject xmlns:dc="http://purl.org/dc/elements/1.1/"
               xmlns:rel="info:fedora/fedora-system:def/relations-external#">
  <pid>tufts:1</pid>
  <file>anatomicaltables00ches.pdf</file>
  <rel:hasModel>info:fedora/cm:Text.PDF</rel:hasModel>
  <dc:title>Anatomical tables of the human body.</dc:title>
  <dc:description>Title page printed in red.</dc:description>
  <dc:description>Several woodcuts signed by the monogrammist "b" appeared first in the Bible of 1490 translated into Italian by Niccol Malermi.</dc:description>
</digitalObject>

  pdf
  node = doc.at_xpath("//digitalObject")
end

