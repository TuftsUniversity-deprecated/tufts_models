require 'spec_helper'

describe CollectionMetadata do
  let(:image1) { FactoryGirl.create(:image) }
  let(:image2) { FactoryGirl.create(:image) }

  context 'set with ids' do
    before do
      subject.member_ids = [image1.id, image2.id]
    end

    describe '#members' do
      it 'accesses members with boxy-operator like an array' do
        expect(subject.members[0]).to eq image1
        expect(subject.members[1]).to eq image2
      end
    end

    it 'adds a member with the shift operator' do
      subject.members << image1
      expect(subject.member_ids).to eq [image1.pid, image2.pid, image1.pid]
      expect(subject.members).to eq [image1, image2, image1]
    end
  end

  context 'set with objects' do
    before do
      subject.members = [image1, image2]
    end

    describe 'member_ids' do
      it 'returns the ids' do
        expect(subject.member_ids).to eq [image1.pid, image2.pid]
      end
    end
  end

end

