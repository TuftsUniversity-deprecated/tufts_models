require 'spec_helper'

describe TuftsPdf do
  describe "to_class_uri" do
    subject { TuftsPdf }
    its(:to_class_uri) { should == 'info:fedora/cm:Text.PDF' }
  end

  it "should have an original_file_datastream" do
    TuftsPdf.original_file_datastreams.should == ["Archival.pdf"]
  end

  describe "an pdf with a pid" do
    before do
      subject.inner_object.pid = 'tufts:MS054.003.DO.02108'
    end
    it "should give a remote url" do
      subject.remote_url_for('Archival.pdf', 'pdf').should == 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MS054/archival_pdf/MS054.003.DO.02108.archival.pdf'
    end
    it "should give a local_path" do
      subject.local_path_for('Archival.pdf', 'pdf').should == "#{Rails.root}/spec/fixtures/local_object_store/data01/tufts/central/dca/MS054/archival_pdf/MS054.003.DO.02108.archival.pdf"
    end
  end
end
