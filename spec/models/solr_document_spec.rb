require 'spec_helper'

describe SolrDocument do
  before { subject['id'] = 'tufts:7'}

  it 'knows if the object is part of a batch' do
    expect(subject.in_a_batch?).to be_falsey
    subject['batch_id_ssim'] = ['1']
    expect(subject.in_a_batch?).to be_truthy
  end

  describe "#preview_fedora_path" do
    it "should always have link to fedora object" do
      url = 'http://localhost:8983/fedora/objects/tufts:7'
      subject['displays_ssi'] = nil
      expect(subject.preview_fedora_path).to eq url
      subject['displays_ssi'] = 'dl'
      expect(subject.preview_fedora_path).to eq url
      subject['displays_ssi'] = 'tufts'
      expect(subject.preview_fedora_path).to eq url
    end
  end

  describe "#preview_dl_path" do
    let(:url) { 'http://dev-dl.lib.tufts.edu/catalog/tufts:7' }
    describe "when displays is 'dl'" do
      before { subject['displays_ssi'] = 'dl' }
      it "has a link to the fedora object" do
        expect(subject.preview_dl_path).to eq url
      end
    end
    describe "when displays is not set" do
      it "has a link to the fedora object" do
        subject['displays_ssi'] = nil
        expect(subject.preview_dl_path).to eq url
        subject['displays_ssi'] = ''
        expect(subject.preview_dl_path).to eq url
      end
    end
    describe "when displays is something else" do
      before { subject['displays_ssi'] = 'tisch'}
      it "has a link to the fedora object" do
        expect(subject.preview_dl_path).to be_nil
      end
    end
    describe "when the object is a template" do
      before do
        subject['displays_ssi'] = 'dl'
        subject['active_fedora_model_ssi'] = 'TuftsTemplate'
      end
      it "has a link to the fedora object" do
        expect(subject.preview_dl_path).to be_nil
      end
    end
  end

  describe 'Templates' do
    before do
      edit_date_key = Solrizer.solr_name("edited_at", :stored_sortable, type: :date)
      @template = SolrDocument.new('active_fedora_model_ssi' => 'TuftsTemplate', edit_date_key => Time.now)
      @pdf = SolrDocument.new('active_fedora_model_ssi' => 'TuftsPdf', edit_date_key => Time.now)
    end

    it 'knows whether or not an object is a template' do
      @template.template?.should be_truthy
      @pdf.template?.should be_falsey
    end

    it 'are not publishable' do
      @template.publishable?.should be_falsey
      @pdf.publishable?.should be_truthy
    end
  end

  describe 'Reviewing an object:' do
    before do
      @doc = SolrDocument.new(
        'active_fedora_model_ssi' => 'TuftsPdf',
        'batch_id_ssim' => ['1'])
    end

    it 'knows if an object has been reviewed already' do
      @doc.reviewed?.should be_falsey
      @doc['qrStatus_tesim'] = Reviewable.batch_review_text
      @doc.reviewed?.should be_truthy
    end

    it 'knows if an object is reviewable' do
      @doc.reviewable?.should be_truthy
    end

    it 'an object that has already been reviewed is not reviewable' do
      @doc['qrStatus_tesim'] = Reviewable.batch_review_text
      @doc.reviewed?.should be_truthy
      @doc.reviewable?.should be_falsey
    end

    it 'templates are not reviewable' do
      @doc['active_fedora_model_ssi'] = 'TuftsTemplate'
      @doc.reviewable?.should be_falsey
    end

    it 'an object that is not in a batch is not reviewable' do
      @doc['batch_id_ssim'] = nil
      @doc.reviewable?.should be_falsey
    end

  end

end
