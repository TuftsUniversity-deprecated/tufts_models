require 'spec_helper'

describe CuratedCollection do

  subject { CuratedCollection.new title: 'some title', creator: ['Bilbo Baggins'] }

  describe "members" do
    context "when it's empty" do
      it "has an empty list of members" do
        expect(subject.members).to eq []
      end

      it "has an empty list of member_ids" do
        expect(subject.member_ids).to eq []
      end
    end

    context "when it's not empty" do
      let(:img1) { FactoryGirl.create('tufts_image') }
      let(:img2) { FactoryGirl.create('tufts_image') }
      let(:img3) { FactoryGirl.create('tufts_image') }

      before do
        subject.members << img1
        subject.members << img2
      end

      it "lists the members" do
        expect(subject.members).to eq [img1, img2]
      end

      it "lists the members_ids" do
        expect(subject.member_ids).to eq [img1.id, img2.id]
      end

      it "adding members persists when saved" do
        subject.save!
        expect(subject.members).to eq [img1, img2]
        subject.member_ids << img3.pid
        subject.save!
        expect(subject.members(true)).to eq [img1, img2, img3]
      end

      describe "to_solr" do
        it 'lists the members' do
          solr_doc = subject.to_solr
          expect(solr_doc['member_ids_ssim']).to eq [img1.id, img2.id]
          expect(solr_doc['member_ids_ssim'].first.class).to eq String
        end

        it 'has fields needed for catalog sort' do
          solr_doc = subject.to_solr
          expect(solr_doc['title_si']).to eq 'some title'
          expect(solr_doc['creator_si']).to eq 'Bilbo Baggins'
        end
      end
    end
  end

  describe "parents" do
    let(:child) { CuratedCollection.create title: 'some title' }
    let(:parent1) { CuratedCollection.create title: 'some title' }
    let(:parent2) { CuratedCollection.create title: 'some title' }
    subject { child.parent_count }

    context "without a parent" do
      it { should eq 0 }
    end

    context "when it has a parent" do
      before do
        parent1.members << child
        parent1.save!
        parent2.members << child
        parent2.save!
      end

      it { should eq 2 }
    end
  end


  describe "to_class_uri" do
    it "sets the displays" do
      expect(subject.displays).to eq ['tdil']
    end

    it "allows tdil as a display" do
      expect(subject.save).to be true
    end
  end

  describe "groups" do
    it "should have read_groups" do
      subject.read_groups = ['public']
      expect(subject.read_groups).to eq ['public']
    end
  end

  describe "apply_depositor_metadata" do
    it "should set the depositor" do
      subject.apply_depositor_metadata('jcoyne')
      expect(subject.edit_users).to eq ['jcoyne']
    end
  end

  it 'has a prefix-formatted PID' do
    subject.save!
    expect(subject.pid).to match /tufts.uc:\d+/
  end

end
