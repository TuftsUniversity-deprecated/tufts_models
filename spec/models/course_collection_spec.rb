require 'spec_helper'

describe CourseCollection do

  subject { CourseCollection.new title: 'some title' }

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
      let(:img1) { create('tufts_image') }
      let(:img2) { create('tufts_image') }
      let(:img3) { create('tufts_image') }

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

      it "deletes members by id" do
        subject.delete_member_by_id(img2.id)
        expect(subject.members).to eq [img1]
      end

      it "ignores delete requests for non-member pids" do
        subject.delete_member_by_id(img3.id)
        expect(subject.members).to eq [img1, img2]
      end

      it "adding members persists when saved" do
        subject.save!
        expect(subject.members).to eq [img1, img2]
        subject.member_ids << img3.pid
        subject.save!
        subject.reload
        expect(subject.members(true)).to eq [img1, img2, img3]
      end

      describe '#to_solr' do
        it 'lists the members' do
          solr_doc = subject.to_solr
          expect(solr_doc['member_ids_ssim']).to eq [img1.id, img2.id]
          expect(solr_doc['member_ids_ssim'].first.class).to eq String
        end
      end
    end
  end

  describe "create" do
    before { CourseCollection.delete_all }
    let(:root) { CourseCollection.root }
    let!(:existing_collection) { CourseCollection.create! title: 'some title' }

    it "should get added to the root collection in the first position" do
      subject.save!
      expect(root.member_ids).to eq([subject.id, existing_collection.id])
    end
  end

  describe "setting collection_attributes" do
    before { CourseCollection.delete_all }
    let(:root) { CourseCollection.root }
    let(:collection1) { create(:course_collection) }
    let(:collection2) { create(:course_collection) }
    let(:collection3) { create(:course_collection) }
    let(:collection4) { create(:course_collection) }
    let(:image) { create(:image) }

    it "assigns multiple members at the root" do
      root.collection_attributes = {
        "0"=>{"id"=>collection3.id, "weight"=>"1", 'parent_page_id' => collection1.id},
        "1"=>{"id"=>collection1.id, "weight"=>"3", 'parent_page_id' => root.id},
        "2"=>{"id"=>collection2.id, "weight"=>"12", 'parent_page_id' => root.id},
        "3"=>{"id"=>collection4.id, "weight"=>"2", 'parent_page_id' => root.id}}
      expect(root.member_ids).to eq [collection4.id, collection1.id, collection2.id]
      expect(collection1.reload.member_ids).to eq [collection3.id]
    end

    it "sets the children 3 deep" do
      root.collection_attributes = {
        "0"=>{"id"=>collection1.id, "weight"=>"0", "parent_page_id"=>"tufts:root_collection"},
        "1"=>{"id"=>collection2.id, "weight"=>"1", "parent_page_id"=>collection1.id},
        "2"=>{"id"=>collection3.id, "weight"=>"0", "parent_page_id"=>collection2.id}
      }
      expect(root.member_ids).to eq [collection1.id]
      expect(collection1.reload.member_ids).to eq [collection2.id]
      expect(collection2.reload.member_ids).to eq [collection3.id]
    end

    it "sets the children to root when parent_page_id is blank" do
      root.collection_attributes = {"0"=>{"id"=>collection3.id, "weight"=>"1", 'parent_page_id' => ''}, "1"=>{"id"=>collection1.id, "weight"=>"3", 'parent_page_id' => ''}, "2"=>{"id"=>collection2.id, "weight"=>"2", 'parent_page_id' => root.id}}
      expect(root.member_ids).to eq [collection3.id, collection2.id, collection1.id]
    end

    context "adding subcollections to the collection" do
      context "with some existing images" do
        before do
          root.member_ids = [image.id]
          root.save!
        end
        it "retains the images" do
          root.collection_attributes = {"0"=>{"id"=>collection1.id, "weight"=>"1", 'parent_page_id' => ''}, "1"=>{"id"=>collection2.id, "weight"=>"2", 'parent_page_id' => ''}}
          root.save!
          expect(root.reload.member_ids).to eq [collection1.id, collection2.id, image.id]
        end
      end
    end

    context "reordering subcollections within a collection" do
      context "with some existing images" do
        before do
          root.member_ids = [collection1.id, image.id, collection2.id]
          root.save!
        end
        it "retains the images" do
          root.collection_attributes = {"0"=>{"id"=>collection1.id, "weight"=>"1", 'parent_page_id' => ''}, "1"=>{"id"=>collection2.id, "weight"=>"0", 'parent_page_id' => ''}}
          expect(root.member_ids).to eq [collection2.id, collection1.id, image.id]
        end
      end
    end

    context "when moving a child up a level" do
      before do
        root.member_ids = [collection1.id]
        collection1.member_ids = [image.id, collection2.id, collection3.id]
        collection1.save!
      end
      it "clears the lower level and preserves the order of the remaining members" do
        # collection2 moves out of collection1 to root
        root.collection_attributes = {
          "0"=>{"id"=>collection1.id, "weight"=>"0", 'parent_page_id' => ''},
          "1"=>{"id"=>collection2.id, "weight"=>"1", 'parent_page_id' => ''},
          "2"=>{"id"=>collection3.id, "weight"=>"2", 'parent_page_id' => collection1.id}
        }
        expect(collection1.reload.member_ids).to eq [image.id, collection3.id]
      end
    end
  end

  describe "parents" do
    let(:child) { CourseCollection.create title: 'some title' }
    let(:parent1) { CourseCollection.create title: 'some title' }
    let(:parent2) { CourseCollection.create title: 'some title' }
    subject { child.parent_count }

    context "without an explicit parent (child of root)" do
      it { should eq 1 }
    end

    context "when it has many parents" do
      before do
        parent1.members << child
        parent1.save!
        parent2.members << child
        parent2.save!
      end

      it { should eq 3 }
    end
  end

  describe "to_class_uri" do
    it "sets the displays" do
      expect(subject.displays).to eq ['trove']
    end

    it "allows trove as a display" do
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

  describe "#ordered_subset?" do
    let(:collection) { CourseCollection.new }
    before do
      collection.member_ids = ['one', 'two', 'three', 'four']
    end
    subject { collection.send(:ordered_subset?, new_ids) }

    context 'with extra elements (not a subset)' do
      let(:new_ids) { ['three', 'four', 'five'] }
      it { should be false }
    end

    context 'out of order' do
      let(:new_ids) { ['three', 'two'] }
      it { should be false }
    end

    context 'same as original' do
      let(:new_ids) { ['one', 'two', 'three', 'four'] }
      it { should be true }
    end

    context 'in order' do
      let(:new_ids) { ['two', 'three'] }
      it { should be true }
    end
  end

  describe "#createdby" do
    subject { CourseCollection.new.createdby }
    it { should eq 'trove' }
  end
end
