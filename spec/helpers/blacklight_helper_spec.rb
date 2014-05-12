require 'spec_helper'

describe BlacklightHelper do

  before do
    config = CatalogController.new.blacklight_config
    helper.stub(:blacklight_config).and_return(config)
  end

  describe '#document_show_link_field' do
    it 'for a template object, it displays the template_name' do
      doc = SolrDocument.new('template_name_tesim' => ['My Template'])
      helper.document_show_link_field(doc).should == :template_name_tesim
    end

    it 'for a non-template object, it falls back to normal blacklight behavior' do
      doc = SolrDocument.new('title_tesim' => ['My Title'])
      helper.document_show_link_field(doc).should == :title_tesim
    end

  end

  describe '#document_heading' do
    it 'for a template object, it displays the temlate_name' do
      doc = SolrDocument.new('template_name_tesim' => ['My Template'])
      helper.document_heading(doc).should == ['My Template']
    end

    it 'for a non-template object, it falls back to normal blacklight behavior' do
      doc = SolrDocument.new('title_tesim' => ['My Title'])
      helper.document_heading(doc).should == ['My Title']
    end
  end

  describe '#render_review_status' do
    let(:doc) { SolrDocument.new('qrStatus_tesim' => status, 'batch_id_ssim' => batch_id) }

    context 'when the object is part of a batch' do
      let(:batch_id) { '1' }

      context 'when the object has been marked as reviewed' do
        let(:status) { Reviewable.batch_review_text }

        it 'returns a checked checkbox that is disabled' do
          display = helper.render_review_status(doc)
          expect(display).to match /checkbox/
          expect(display).to match /checked/
          expect(display).to match /disabled/
        end
      end

      context 'when the object has not been reviewed' do
        let(:status) { 'some other status' }

        it 'returns an unchecked checkbox that is disabled' do
          display = helper.render_review_status(doc)
          expect(display).to     match /checkbox/
          expect(display).to_not match /checked/
          expect(display).to     match /disabled/
        end
      end
    end

    context "when the object isn't part of a batch" do
      let(:batch_id) { nil }
      let(:status) { 'some other status' }

      it 'returns nil' do
        display = helper.render_review_status(doc)
        expect(display).to be_nil
      end
    end
  end

  describe '#fedora_object_state' do
    let(:solr_doc) { SolrDocument.new(id: 'some_id:123', object_state_ssi: 'A') }
    let(:blacklight_options_hash) {
      { :field => "object_state_ssi", :document => solr_doc }
    }

    it 'returns a human-readable state' do
      state = helper.fedora_object_state(blacklight_options_hash)
      expect(state).to eq 'Active'
    end

    it 'gracefully handles unexpected states' do
      solr_doc[:object_state_ssi] = nil
      expect(helper.fedora_object_state(blacklight_options_hash)).to be_nil

      solr_doc[:object_state_ssi] = 'something unexpected'
      expect(helper.fedora_object_state(blacklight_options_hash)).to eq 'something unexpected'
    end
  end

end
