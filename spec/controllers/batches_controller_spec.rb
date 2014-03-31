require 'spec_helper'

describe BatchesController do
  let(:batch_template_update) { FactoryGirl.create(:batch_template_update,
                                                   pids: records.map(&:id)) }
  let(:records) { [FactoryGirl.create(:tufts_pdf)] }

  describe "non admin" do
    it 'denies access to create' do
      post :create
      response.should redirect_to(new_user_session_path)
    end
    it 'denies access to show' do
      get :index
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


    describe "POST 'create'" do

      describe 'error path - no pids were selected:' do
        it 'redirects to previous page' do
          allow(controller.request).to receive(:referer) { catalog_index_path }
          post :create, batch: { pids: [] }
          response.should redirect_to(request.referer)
        end

        it 'redirects to root if there is no referer' do
          post :create, batch: { pids: [] }
          response.should redirect_to(root_path)
        end

        it 'sets the flash' do
          post :create, batch: { pids: [] }
          flash[:error].should == 'Please select some records to do batch updates.'
        end
      end


      describe 'error path - batch fails to run:' do
        it 'sets the flash' do
          BatchPublish.any_instance.stub(:save) { true }
          BatchPublish.any_instance.stub(:run) { false }
          post :create, batch: { pids: ['pid:1'], type: 'BatchPublish' }
          flash[:error].should == 'Unable to run batch, please try again later.'
        end

        it "doesn't create a batch object" do
          batch_count = Batch.count
          BatchPublish.any_instance.stub(:run) { false }
          post 'create', batch: FactoryGirl.attributes_for(:batch_publish)
          expect(Batch.count).to eq batch_count
        end

        it 'still assigns @batch' do
          BatchPublish.any_instance.stub(:run) { false }
          attributes = FactoryGirl.attributes_for(:batch_publish)
          post 'create', batch: attributes
          expect(assigns[:batch].pids).to eq attributes[:pids]
          expect(assigns[:batch].new_record?).to be_true
        end
      end


      describe "for batch publishing - happy path:" do
        it 'creates a batch' do
          BatchPublish.any_instance.stub(:run) { true }
          batch_count = Batch.count
          post 'create', batch: FactoryGirl.attributes_for(:batch_publish)
          expect(Batch.count).to eq batch_count + 1
        end

        it 'assigns @batch' do
          BatchPublish.any_instance.stub(:run) { true }
          post 'create', batch: FactoryGirl.attributes_for(:batch_publish)
          expect(assigns[:batch].class).to eq BatchPublish
        end

        it "runs the batch" do
          batch = Batch.new(FactoryGirl.attributes_for(:batch_publish))
          allow(Batch).to receive(:new) { batch }
          expect(batch).to receive(:run) { true }
          post 'create', batch: FactoryGirl.attributes_for(:batch_publish)
        end

        it "redirects to batch#show" do
          BatchPublish.any_instance.stub(:run) { true }
          post 'create', batch: FactoryGirl.attributes_for(:batch_publish)
          response.should redirect_to(batch_path(assigns[:batch]))
        end
      end

      describe "for batch publishing - error path:" do
        it "redirects to previous page" do
          BatchPublish.any_instance.stub(:save) { true }
          BatchPublish.any_instance.stub(:run) { false }
          allow(controller.request).to receive(:referer) { catalog_index_path }
          post :create, batch: { pids: ['pid:1'], type: 'BatchPublish' }
          response.should redirect_to(request.referer)
        end
      end


      describe "for template updates" do
        def post_create(overrides={})
          BatchTemplateUpdate.any_instance.stub(:run) { true }
          post 'create', batch: FactoryGirl.attributes_for(:batch_template_update).merge(overrides)
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
          batch = Batch.new({type: "BatchTemplateUpdate", pids: ['pid:1'], template_id: "tufts:3", id: '1'})
          expect(batch).to receive(:save) { true }
          expect(batch).to receive(:run) { true }
          allow(Batch).to receive(:new) { batch }
          post 'create', batch: { type: "BatchTemplateUpdate" }
        end

        it "assigns @batch" do
          post_create
          expect(assigns[:batch].class).to eq BatchTemplateUpdate
        end

        it 'renders new (the 2nd page of the form) to select the template' do
          post 'create', batch: { type: 'BatchTemplateUpdate', template_id: nil, pids: ['pid:1'] }, batch_form_page: '1'
          expect(flash).to be_empty
          expect(assigns(:batch).errors).to be_empty
          response.should render_template(:new)
        end

        it "renders new when there are form errors" do
          post_create(template_id: nil)
          expect(flash).to be_empty
          assigns(:batch).errors[:template_id].include?("can't be blank").should be_true
          response.should render_template(:new)
        end

        it 'renders new when batch fails to run' do
          BatchTemplateUpdate.any_instance.stub(:save) { true }
          BatchTemplateUpdate.any_instance.stub(:run) { false }
          post 'create', batch: {type: "BatchTemplateUpdate", pids: ['pid:1']}
          response.should render_template(:new)
        end
      end
    end

    describe "GET 'index'" do
      describe 'happy path' do
        let(:batches) do
          [FactoryGirl.create(:batch_template_update, created_at: 2.days.ago),
           FactoryGirl.create(:batch_publish, created_at: 1.day.ago)]
        end
        before do
          Batch.delete_all
          batches
          get :index
        end

        it "returns http success" do
          response.should be_success
        end

        it 'should render the index template' do
          response.should render_template(:index)
        end

        it 'assigns @batches' do
          expect(assigns[:batches]).to eq batches.sort_by(&:created_at).reverse
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

        it 'assigns @batch and @records' do
          expect(assigns[:batch].id).to eq batch_template_update.id
          expected = records.reduce({}){|acc, r| acc.merge(r.pid => r)}
          expect(assigns[:records_by_pid]).to eq expected
        end
      end
    end
  end
end
