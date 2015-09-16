require 'spec_helper'

describe WithNestedMembers do
  let(:img1) {TuftsImage.new pid: 'tufts:1'}
  let(:img2) {TuftsImage.new pid: 'tufts:2'}
  let(:img3) {TuftsImage.new pid: 'tufts:3'}
  let(:img4) {TuftsImage.new pid: 'tufts:4'}
  let(:video5) {TuftsVideo.new pid: 'tufts:5'}
  let(:coll1) {CourseCollection.new pid: 'tufts.uc:a', members: [img2, img3, video5]}
  let(:all_models) { [subject, img1, img2, img3, img4, video5, coll1] }
  let(:solr_docs) do
    all_models.reduce({}) do |result, model|
      result.merge(model.pid => model.to_solr.merge('id' => model.pid,
                                                    'has_model_ssim' => [model.class.to_class_uri]))
    end
  end
  let(:members) do
    [img1, coll1, img4]
  end

  subject {CourseCollection.new pid: 'tufts.uc:b', title: 'some title', creator: ['Bilbo Baggins'], members: members}

  before do
    allow(ActiveFedora::SolrService).to receive(:construct_query_for_pids) { |pids| pids }
    allow(ActiveFedora::SolrService).to receive(:query) { |pids| solr_docs.values_at(*pids) }
    allow(ActiveFedora::Base).to receive(:find) { |pid| all_models.find{|m| m.pid == pid} }
    allow(ActiveFedora::Base).to receive(:exists?) { true }
  end

  describe  '#falttened_member_ids_with_collections' do
    it 'gets all descendant_ids and their parent collection solr docs' do
      expected = [
        [img1.pid, solr_docs[subject.pid]],
        [img2.pid, solr_docs[coll1.pid]],
        [img3.pid, solr_docs[coll1.pid]],
        [video5.pid, solr_docs[coll1.pid]],
        [img4.pid, solr_docs[subject.pid]]]
      expect(subject.flattened_member_ids_with_collections.force).to eq expected
    end

    context "with a deleted member" do
      before do
        allow(ActiveFedora::Base).to receive(:exists?) {|pid| pid != img2.pid }
      end

      it 'skips the deleted item' do
        expected = [
          [img1.pid, solr_docs[subject.pid]],
          [img3.pid, solr_docs[coll1.pid]],
          [video5.pid, solr_docs[coll1.pid]],
          [img4.pid, solr_docs[subject.pid]]]
        expect(subject.flattened_member_ids_with_collections.force).to eq expected
      end
    end
  end

  describe '#flattened_member_ids' do
    it 'gets all descendants' do
      expected = [img1, img2, img3, video5, img4].map(&:pid)
      expect(subject.flattened_member_ids.force).to eq expected
    end
  end

  describe '#positions_of_members' do
    it 'gets positions (giving nil for collections)' do
      expected = [0, nil, 4]
      expect(subject.positions_of_members).to eq expected
    end
  end
end
