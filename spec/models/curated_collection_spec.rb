require 'spec_helper'

describe CuratedCollection do

  subject { CuratedCollection.new title: 'some title', creator: ['Bilbo Baggins'] }

  describe "#to_s" do
    it "displays the title" do
      expect(subject.to_s).to eq 'some title'
    end
  end

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
      let(:img1) { FactoryGirl.create(:tufts_image) }
      let(:img2) { FactoryGirl.create(:tufts_image) }
      let(:img3) { FactoryGirl.create(:tufts_image) }

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

      describe "deleting a member" do
        let(:child_collection) { FactoryGirl.create(:curated_collection) }
        before do
          subject.members << child_collection
          subject.save!
        end
        context "that is an image" do
          before { img2.destroy }
          it "removes the reference to the deleted image from the members" do
            expect(subject.reload.member_ids).to eq [img1.id, child_collection.id]
          end
        end

        context "that is an collection" do
          before { child_collection.destroy }
          it "removes the reference to the deleted collection from the members" do
            expect(subject.reload.member_ids).to eq [img1.id, img2.id]
          end
        end
      end

      describe "to_solr" do
        it 'lists the members' do
          solr_doc = subject.to_solr
          expect(solr_doc['member_ids_ssim']).to eq [img1.id, img2.id]
          expect(solr_doc['member_ids_ssim'].first.class).to eq String
        end

        it "indexes whether this is a root or not" do
          solr_doc = subject.to_solr
          expect(solr_doc['is_root_bsi']).to be false
        end

        it 'has fields needed for catalog sort' do
          solr_doc = subject.to_solr
          expect(solr_doc['title_si']).to eq 'some title'
          expect(solr_doc['creator_si']).to eq 'Bilbo Baggins'
        end
      end
    end
  end

  describe "not_containing" do
    let(:child) { CuratedCollection.create title: 'some title' }
    let(:parent) { CuratedCollection.create title: 'some title', members: [child] }

    it "excludes collections with the given pid" do
      expect(CuratedCollection.not_containing(child.pid)).to_not include(parent)
      expect(CuratedCollection.not_containing(child.pid)).to include(child)
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

    context "with multple parents" do
      before do
        parent1.members << child
        parent1.save!
        parent2.members << child
        parent2.save!
      end

      it { should eq 2 }

    end

    context "with one parent" do
      before do
        parent1.members << child
        parent1.save!
      end

      it "should have a parent" do
        expect(child.parent).to eq parent1
      end

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
