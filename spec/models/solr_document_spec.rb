require 'spec_helper'

describe SolrDocument do
  before { subject['id'] = 'tufts:7'}

  describe "#preview_fedora_path" do
    describe "should always have link to fedora object" do
      before { subject['displays_ssi'] = nil }
      its(:preview_fedora_path) {should == 'http://localhost:8983/fedora/objects/tufts:7'}
      before { subject['displays_ssi'] = 'dl' }
      its(:preview_fedora_path) {should == 'http://localhost:8983/fedora/objects/tufts:7'}
      before { subject['displays_ssi'] = 'tufts' }
      its(:preview_fedora_path) {should == 'http://localhost:8983/fedora/objects/tufts:7'}
    end
  end
  
  describe "#preview_dl_path" do
    describe "when displays is 'dl'" do
      before { subject['displays_ssi'] = 'dl' }
      its(:preview_dl_path) {should == 'http://dev-dl.lib.tufts.edu/catalog/tufts:7'}
    end
    describe "when displays is not set" do
      before { subject['displays_ssi'] = nil }
      its(:preview_dl_path) {should == 'http://dev-dl.lib.tufts.edu/catalog/tufts:7'}
      before { subject['displays_ssi'] = ''}
      its(:preview_dl_path) {should == 'http://dev-dl.lib.tufts.edu/catalog/tufts:7'}
    end
    describe "when displays is something else" do
      before { subject['displays_ssi'] = 'tisch'}
      its(:preview_dl_path) {should == nil}
    end
    describe "when the object is a template" do
      before do
        subject['displays_ssi'] = 'dl'
        subject['active_fedora_model_ssi'] = 'TuftsTemplate'
      end
      its(:preview_dl_path) {should == nil}
    end
  end

  describe 'Templates' do
    before do
      edit_date_key = Solrizer.solr_name("edited_at", :stored_sortable, type: :date)
      @template = SolrDocument.new('active_fedora_model_ssi' => 'TuftsTemplate', edit_date_key => Time.now)
      @pdf = SolrDocument.new('active_fedora_model_ssi' => 'TuftsPdf', edit_date_key => Time.now)
    end

    it 'knows whether or not an object is a template' do
      @template.template?.should be_true
      @pdf.template?.should be_false
    end

    it 'are not publishable' do
      @template.publishable?.should be_false
      @pdf.publishable?.should be_true
    end
  end

  describe 'Reviewing an object:' do
    before do
      @doc = SolrDocument.new(
        'active_fedora_model_ssi' => 'TuftsPdf',
        'batch_id_ssim' => ['1'])
    end

    it 'knows if an object has been reviewed already' do
      @doc.reviewed?.should be_false
      @doc['qrStatus_tesim'] = Reviewable.batch_review_text
      @doc.reviewed?.should be_true
    end

    it 'knows if an object is reviewable' do
      @doc.reviewable?.should be_true
    end

    it 'an object that has already been reviewed is not reviewable' do
      @doc['qrStatus_tesim'] = Reviewable.batch_review_text
      @doc.reviewed?.should be_true
      @doc.reviewable?.should be_false
    end

    it 'templates are not reviewable' do
      @doc['active_fedora_model_ssi'] = 'TuftsTemplate'
      @doc.reviewable?.should be_false
    end

    it 'an object that is not in a batch is not reviewable' do
      @doc['batch_id_ssim'] = nil
      @doc.reviewable?.should be_false
    end

  end

end
