require 'spec_helper'

describe SolrDocument do
  before { subject['id'] = 'tufts:7'}

  it 'knows if the object is part of a batch' do
    expect(subject).to_not be_in_a_batch
    subject['batch_id_ssim'] = ['1']
    expect(subject).to be_in_a_batch
  end

  describe "#preview_fedora_path" do
    it "should always have link to fedora object" do
      url = 'http://localhost:8983/fedora/objects/tufts:7'
      subject['displays_ssim'] = nil
      expect(subject.preview_fedora_path).to eq url
      subject['displays_ssim'] = ['dl']
      expect(subject.preview_fedora_path).to eq url
      subject['displays_ssim'] = ['tufts']
      expect(subject.preview_fedora_path).to eq url
    end
  end

  describe "#preview_dl_path" do
    let(:url) { 'http://dev-dl.lib.tufts.edu/catalog/tufts:7' }
    describe "when displays is 'dl'" do
      before { subject['displays_ssim'] = ['dl'] }
      it "has a link to the fedora object" do
        expect(subject.preview_dl_path).to eq url
      end
    end
    describe "when displays is not set" do
      it "has a link to the fedora object" do
        subject['displays_ssim'] = nil
        expect(subject.preview_dl_path).to eq url
        subject['displays_ssim'] = ['']
        expect(subject.preview_dl_path).to eq url
      end
    end
    describe "when displays is something else" do
      before { subject['displays_ssim'] = ['tisch']}
      it "has a link to the fedora object" do
        expect(subject.preview_dl_path).to be_nil
      end
    end
    describe "when the object is a template" do
      before do
        subject['displays_ssim'] = ['dl']
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
      expect(@template).to be_template
      expect(@pdf).to_not be_template
    end

    it 'are not publishable' do
      expect(@template).to_not be_publishable
      expect(@pdf).to be_publishable
    end
  end

  describe 'Reviewing an object:' do
    before do
      @doc = SolrDocument.new(
        'active_fedora_model_ssi' => 'TuftsPdf',
        'batch_id_ssim' => ['1'])
    end

    it 'knows if an object has been reviewed already' do
      expect(@doc).to_not be_reviewed
      @doc['qrStatus_tesim'] = Reviewable.batch_review_text
      expect(@doc).to be_reviewed
    end

    it 'knows if an object is reviewable' do
      expect(@doc).to be_reviewable
    end

    it 'an object that has already been reviewed is not reviewable' do
      @doc['qrStatus_tesim'] = Reviewable.batch_review_text
      expect(@doc).to be_reviewed
      expect(@doc).to_not be_reviewable
    end

    it 'templates are not reviewable' do
      @doc['active_fedora_model_ssi'] = 'TuftsTemplate'
      expect(@doc).to_not be_reviewable
    end

    it 'an object that is not in a batch is not reviewable' do
      @doc['batch_id_ssim'] = nil
      expect(@doc).to_not be_reviewable
    end

  end

end
