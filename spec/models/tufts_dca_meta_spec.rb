require 'spec_helper'

describe TuftsDcaMeta do

  context "a legacy object, created when dc elements was the default namespace" do
    let(:xml) { '<dc xmlns="http://purl.org/dc/elements/1.1/" xmlns:dcadesc="http://nils.lib.tufts.edu/dcadesc/" xmlns:dcatech="http://nils.lib.tufts.edu/dcatech/" xmlns:xlink="http://www.w3.org/1999/xlink" version="0.1">
  <creator>Grant, Spencer</creator>
  <description>This date is approximate. </description>
  <publisher>Tufts University. Digital Collections and Archives.</publisher>
  <source>MS171</source>
  <date.created>1973</date.created>
  <date.issued>2014-06-23</date.issued>
  <date.available>2012-05-14T00:00:00</date.available>
  <type>Image</type>
  <format>image/tiff</format>
  <rights>http://dca.tufts.edu/ua/access/rights.html</rights>
  <title>Tufts and Jackson College alumni socializing at a picnic table at an Alumni Day event</title>
</dc>'
    }
    let(:datastream) { TuftsDcaMeta.new(nil, 'DCA-META').tap { |ds| ds.content = xml } }

    describe "reading a property" do
      it "should read" do
        expect(datastream.creator).to eq ['Grant, Spencer']
      end
    end

    describe "writing a property" do
      it "should write" do
        # write more elements than currently exist. This forces a new element to be added to the
        # document rather than updating what is already there.
        datastream.publisher = ['Tufts University Library', 'Digital Collections and Archives.']

        expect(datastream.publisher).to eq ['Tufts University Library', 'Digital Collections and Archives.']
      end
    end

  end
end
