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

  describe "attributes" do
    it "should have createdby fields" do
      expect(subject.createdby).to be_nil
      subject.createdby = Contribution::SELFDEP
      expect(subject.createdby).to eq Contribution::SELFDEP
    end
    it "should have creatordept" do
      
      expect(subject.creatordept).to be_nil
      subject.creatordept = 'UA005.014'
      expect(subject.creatordept).to eq 'UA005.014'
    end

  end

  describe "to_solr" do
    before do
      subject.stub(pid: 'foo:123')
    end
    let(:solr_doc) {subject.to_solr}
    describe "on a self-deposit" do
      before do
        subject.createdby = Contribution::SELFDEP
      end
      it "should have deposit_method_ssi" do
        solr_doc['deposit_method_ssi'].should == 'self-deposit'
      end
    end
  end
end
