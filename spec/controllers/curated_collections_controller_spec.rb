require 'spec_helper'

describe CuratedCollectionsController do

  describe "for a not-signed in user" do
    describe "create" do
      it "redirects to sign in" do
        post :create
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "for a signed in user" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    describe "POST 'create'" do
      it "redirects" do
        count = CuratedCollection.count
        post 'create', curated_collection: {title: 'foo'}
        expect(CuratedCollection.count).to eq (count + 1)
        expect(response.status).to eq 302
      end

      context 'with a bad title' do
        it "displays the form to fix the title" do
          count = CuratedCollection.count
          post 'create', curated_collection: {title: nil}
          expect(CuratedCollection.count).to eq count
          expect(response).to be_successful
          expect(response).to render_template(:new)
        end
      end
    end

    describe "PATCH 'create'" do
      it "returns http success" do
        collection = CuratedCollection.create(title: 'foo')
        patch 'append_to', id: collection.id
        expect(response).to be_successful
        pending "need to implement :member_ids on CuratedCollection"
        expect(collection.reload.member_ids).to include('new:member')
      end
    end
  end
end
