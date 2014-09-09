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

      it "responds to some array methods" do
        expect(subject.members).to respond_to :each
        expect(subject.members).to respond_to :each_with_index
        expect(subject.members).to respond_to :empty?
        expect(subject.members).to respond_to :size
      end
    end

    it 'adds a member with the shift operator' do
      subject.members << image1
      expect(subject.member_ids).to eq [image1.pid, image2.pid, image1.pid]
      expect(subject.members).to eq [image1, image2, image1]
    end

    describe 'replacing the list' do
      it 'can be re-set' do
        subject.member_ids = [image2.id, image1.id]
        expect(subject.member_ids).to eq [image2.id, image1.id]
      end
    end

    describe '#delete_member_at' do
      it 'deletes a member from the list' do
        subject.delete_member_at(1)
        expect(subject.members).to eq [image1]
        subject.delete_member_at(0)
        expect(subject.members).to eq []
      end
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


  context "when a member is deleted" do
    before do
      subject.members = [image1, image2]
      image1.delete
    end

    describe 'members' do
      it 'returns the non-deleted elements' do
        expect(subject.members).to eq [image2]
        expect(subject.member_ids).to eq [image2.pid]
      end
    end
  end
end
