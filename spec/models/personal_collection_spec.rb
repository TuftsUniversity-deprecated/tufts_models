require 'spec_helper'

describe PersonalCollection do

  subject { PersonalCollection.new title: 'some title' }

  describe "create" do
    before { PersonalCollection.delete_all }
    let(:user) { FactoryGirl.create(:user) }
    let(:root) { user.personal_collection }
    let!(:existing_collection) { PersonalCollection.create! title: 'some title', active_user: user }

    before do
      subject.active_user = user
    end

    it "should get added to the root collection in the first position" do
      subject.save!
      expect(root.member_ids).to eq([subject.id, existing_collection.id])
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
    end

    context "when it has a child collection" do
      let(:child_collection) { create(:personal_collection) }

      before do
        subject.members << child_collection
        subject.save!
      end

      describe "#delete" do
        it "should destroy the child collection too" do
          expect { subject.destroy }.to change { PersonalCollection.count }.by(-2)
          expect(PersonalCollection).to_not exist(child_collection.pid)
        end
      end

      describe "representative_image" do
        context "when there is a child images" do
          let(:image) { create('tufts_image') }
          before do
            subject.members << image
            subject.save!
          end

          it "should find the first nested image" do
            expect(subject.representative_image).to eq image
          end
        end

        context "when there are grandchild images" do
          let(:image) { create('tufts_image') }
          before do
            child_collection.members << image
            child_collection.save!
          end

          it "should find the first nested image" do
            expect(subject.representative_image).to eq image
          end
        end

        context "when there are no child images" do
          it "should return nil" do
            expect(subject.representative_image).to be_nil
          end
        end
      end
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

  describe "#createdby" do
    subject { CourseCollection.new.createdby }
    it { should eq 'trove' }
  end
end
