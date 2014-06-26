require 'spec_helper'

describe CuratedCollectionsController, if: Tufts::Application.til? do

  let(:image) { FactoryGirl.create(:image) }

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

    context "on an existing collection" do
      let(:collection) { FactoryGirl.create(:curated_collection, user: user) }

      describe "GET 'show'" do
        it "returns http success" do
          get :show, id: collection.id
          expect(response).to be_successful
          expect(assigns[:curated_collection]).to eq collection
        end
      end

      describe "PATCH 'append_to'" do
        it "returns http success" do
          patch 'append_to', id: collection.id, pid: image.pid
          expect(response).to be_successful
          expect(collection.reload.members).to eq [image]
        end
      end
    end
  end
end
