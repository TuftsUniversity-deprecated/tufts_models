require 'spec_helper'

describe BlacklightConfigurationHelper do

  describe "document_show_fields" do
    before do
      allow(helper).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
    end

    let(:document) { SolrDocument.new('active_fedora_model_ssi' => model.to_s) }

    context "when the document is an image" do
      let(:model) { TuftsImage }
      subject { helper.document_show_fields document }
      it "should display creator, description, date_created" do
        expect(subject.keys).to eq ["creator_tesim", "description_tesim", "date_created_tesim"]
      end
    end

    context "when the document is an pdf" do
      let(:model) { TuftsPdf }
      subject { helper.document_show_fields document }
      it "should display all the fields" do
        expect(subject.keys).to eq ["id", "object_state_ssi", "creator_tesim", "source2_tesim", "description_tesim", "identifier_tesim", "dateCreated_tesim", "date_created_tesim", "dateAvailable_tesim", "dateIssued_tesim", "rights_tesim", "bilbiographicCitation_tesim", "publisher_tesim", "type2_tesim", "format2_tesim", "extent_tesim", "persname_tesim", "corpname_tesim", "geogname_tesim", "genre_tesim", "funder_tesim", "temporal_tesim", "resolution_tesim", "bitDepth_tesim", "colorSpace_tesim", "filesize_tesim", "has_model_ssim", "active_fedora_model_ssi"]
      end
    end

  end
end
