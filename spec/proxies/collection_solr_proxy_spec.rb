require 'spec_helper'

describe CollectionSolrProxy do

  describe "id" do
    subject { CollectionSolrProxy.new(id: 'tufts.uc:77', title: 'Test title') }

    it "should have id" do
      expect(subject.id).to eq 'tufts.uc:77'
    end

    it "should have title" do
      expect(subject.title).to eq 'Test title'
    end
  end

  describe "exists?" do
    context "when it doesn't exist" do
      subject { CollectionSolrProxy.new(id: 'foo:bar', title: 'Test title') }
      it "should be false" do
        expect(subject.exists?).to be false
      end
    end
    context "when it exists" do
      subject { CollectionSolrProxy.new(id: FactoryGirl.create(:personal_collection).id) }
      it "should be true" do
        expect(subject.exists?).to be true
      end
    end

  end

  describe "collection_member_ids" do
    let(:solr) { ActiveFedora::SolrService.instance.conn }
    subject { CollectionSolrProxy.new(id: 'tufts.uc:77', member_ids: ['foo:2', 'foo:1', 'foo:3'], klass: CourseCollection ).collection_member_ids }

    before do
      solr.add has_model_ssim: [CourseCollection.to_class_uri], id: 'foo:1'
      solr.add has_model_ssim: [CourseCollection.to_class_uri], id: 'foo:2'
      solr.add has_model_ssim: [TuftsImage.to_class_uri], id: 'foo:3'
      solr.commit
    end

    it "should return them in their correct order" do
      expect(subject).to eq ['foo:2', 'foo:1']
    end
  end


end
