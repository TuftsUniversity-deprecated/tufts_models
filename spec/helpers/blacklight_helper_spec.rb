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
    let(:doc) { SolrDocument.new('qrStatus_tesim' => status) }
    let(:opts) {{ field: 'qrStatus_tesim', document: doc }}

    context 'when the object has been marked as reviewed' do
      let(:status) { Reviewable.batch_review_text }

      it 'returns a checked checkbox that is disabled' do
        display = helper.render_review_status(opts)
        expect(display).to match /checkbox/
        expect(display).to match /checked/
        expect(display).to match /disabled/
      end
    end

    context 'when the object has not been reviewed' do
      let(:status) { 'some other status' }

      it 'returns an unchecked checkbox that is disabled' do
        display = helper.render_review_status(opts)
        expect(display).to     match /checkbox/
        expect(display).to_not match /checked/
        expect(display).to     match /disabled/
      end
    end

    context "when it can't determine the review status" do
      it 'returns nil' do
        status = helper.render_review_status(nil)
        expect(status).to be_nil

        status = helper.render_review_status({ document: {} })
        expect(status).to be_nil
      end
    end
  end

end
