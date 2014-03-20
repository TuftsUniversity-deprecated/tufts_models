require 'spec_helper'

describe BatchesController do
  let(:batch_template_update) { FactoryGirl.create(:batch_template_update, pids: docs.map(&:id)) }
  let(:docs) { [FactoryGirl.create(:tufts_pdf)] }

  describe "non admin" do
    it 'denies access to new' do
      get :new
      response.should redirect_to(new_user_session_path)
    end
    it 'denies access to create' do
      post :create
      response.should redirect_to(new_user_session_path)
    end
    it 'denies access to show' do
      get :show, id: batch_template_update.id
      response.should redirect_to(new_user_session_path)
    end
  end

  describe "an admin" do
    before do
      @user = FactoryGirl.create(:admin)
      sign_in @user
    end

    describe "GET 'new'" do
      describe 'happy path' do
        before do
          allow(controller.request).to receive(:referer) { catalog_index_path }
          get :new, batch: {pids: ["tufts:1"]}
        end

        it "returns http success" do
          response.should be_success
        end

        it 'should render the new template' do
          response.should render_template(:new)
        end

        it 'assigns @batch' do
          assigns[:batch].pids.should == ["tufts:1"]
        end
      end

      describe 'with no referer and no pids' do
        it 'should redirect to root' do
          get :new, batch: {pids: []}
          response.should redirect_to(root_path)
        end
      end

      describe 'with no pids' do
        it "redirects to previous page" do
          allow(controller.request).to receive(:referer) { catalog_index_path }
          get :new, batch: {pids: []}
          response.should redirect_to(request.referer)
        end

        it "sets the flash" do
          get :new, batch: {pids: []}
          flash[:error].should == 'Please select some documents to do batch updates.'
        end
      end
    end

    describe "POST 'create'" do
      describe "for template updates" do
        def post_create(overrides={})
          BatchTemplateUpdate.any_instance.stub(:run) { true }
          post 'create', batch: FactoryGirl.attributes_for(:batch_template_update, type: 'BatchTemplateUpdate').merge(overrides)
        end

        before do
          @batch_count = Batch.count
        end

        it "redirects to batch#show" do
          post_create
          response.should redirect_to(batch_path(assigns[:batch]))
        end

        it "creates a batch object" do
          post_create
          expect(Batch.count).to eq @batch_count + 1
        end

        it "assigns the current user as the creator" do
          root_user = FactoryGirl.create(:user)
          post_create creator_id: root_user.id
          expect(assigns[:batch].creator).to eq @user
        end

        it "runs the batch" do
          batch = Batch.new
          expect(batch).to receive(:run) { true }
          allow(Batch).to receive(:new) { batch }
          post 'create', batch: {type: "BatchTemplateUpdate", pids: [], template_id: "tufts:3"}
        end

        it "assigns @batch" do
          post_create
          expect(assigns[:batch].class).to eq BatchTemplateUpdate
        end

        it "renders new when there are form errors" do
          post_create(template_id: nil)
          expect(flash).to be_empty
          response.should render_template(:new)
        end

        describe "when batch fails to run" do
          it "renders new and sets the flash" do
            BatchTemplateUpdate.any_instance.stub(:save) { true }
            BatchTemplateUpdate.any_instance.stub(:run) { false }
            post 'create', batch: {type: "BatchTemplateUpdate"}
            expect(flash[:error]).to eq "Unable to run batch, please try again later."
            response.should render_template(:new)
          end

          it "doesn't create a batch object" do
            BatchTemplateUpdate.any_instance.stub(:run) { false }
            post 'create', batch: FactoryGirl.attributes_for(:batch_template_update, type: 'BatchTemplateUpdate')
            expect(Batch.count).to eq @batch_count
          end

          it "still assigns @batch" do
            BatchTemplateUpdate.any_instance.stub(:run) { false }
            attributes = FactoryGirl.attributes_for(:batch_template_update, type: 'BatchTemplateUpdate')
            post 'create', batch: attributes
            expect(assigns[:batch].template_id).to eq attributes[:template_id]
            expect(assigns[:batch].new_record?).to be_true
          end
        end
      end
    end

    describe "GET 'show'" do
      describe 'happy path' do
        before do
          get :show, id: batch_template_update.id
        end

        it "returns http success" do
          response.should be_success
        end

        it 'should render the new template' do
          response.should render_template(:show)
        end

        it 'assigns @batch, @documents, and @jobs' do
          expect(assigns[:batch].id).to eq batch_template_update.id
          expect(assigns[:documents].map(&:id).sort).to eq docs.map(&:id).sort
          expect(assigns[:jobs].map(&:id).sort).to eq jobs.map(&:id).sort
        end
      end
    end
  end
end
