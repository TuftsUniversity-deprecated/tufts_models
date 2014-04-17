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
    it 'denies access to index' do
      get :index
      response.should redirect_to(new_user_session_path)
    end
    it 'denies access to show' do
      get :show, id: batch_template_update.id
      response.should redirect_to(new_user_session_path)
    end
    it 'denies access to new_template_import' do
      get :new_template_import
      response.should redirect_to(new_user_session_path)
    end
    it 'denies access to new_xml_import' do
      get :new_xml_import
      response.should redirect_to(new_user_session_path)
    end
  end

  describe "an admin" do
    before do
      @user = FactoryGirl.create(:admin)
      sign_in @user
    end

    describe "GET 'new_template_import'" do
      before { get :new_template_import }

      it "returns http success" do
        response.should be_success
      end

      it 'should render the form' do
        response.should render_template(:new_template_import)
      end

      it 'assigns @batch' do
        expect(assigns[:batch].class).to eq BatchTemplateImport
      end
    end

    describe "GET 'new_xml_import'" do
      before { get :new_xml_import }

      it "returns http success" do
        response.should be_success
      end

      it 'should render the form' do
        response.should render_template(:new_xml_import)
      end

      it 'assigns @batch' do
        expect(assigns[:batch].class).to eq BatchXmlImport
      end
    end

    describe "POST 'create'" do

      describe 'error path - no batch type selected' do
        it 'redirects to previous page' do
          allow(controller.request).to receive(:referer) { catalog_index_path }
          post :create, batch: { type: nil }
          response.should redirect_to(request.referer)
        end

        it 'redirects to root if there is no referer' do
          post :create, batch: { type: nil }
          response.should redirect_to(root_path)
        end

        it 'sets the flash' do
          post :create, batch: { type: nil }
          flash[:error].should == 'Unable to handle batch request.'
        end
      end

      describe 'template import' do
        describe 'happy path' do
          it 'assigns the current user as the creator' do
            different_user = FactoryGirl.create(:admin)
            attrs = FactoryGirl.attributes_for(:batch_template_import, creator_id: different_user.id)
            post 'create', batch: attrs
            expect(assigns[:batch].creator).to eq controller.current_user
          end

          it 'creates a batch' do
            batch_count = Batch.count
            post 'create', batch: FactoryGirl.attributes_for(:batch_template_import)
            expect(Batch.count).to eq batch_count + 1
          end

          it 'assigns @batch' do
            post 'create', batch: FactoryGirl.attributes_for(:batch_template_import)
            expect(assigns[:batch].class).to eq BatchTemplateImport
          end

          it 'redirects to the batch edit page' do
            post 'create', batch: FactoryGirl.attributes_for(:batch_template_import)
            expect(response).to redirect_to(edit_batch_path(assigns[:batch]))
          end
        end

        describe 'error path' do
          it 'renders :new_template_import form' do
            post 'create', batch: { type: 'BatchTemplateImport'}
            expect(response).to render_template :new_template_import
          end
        end
      end

      describe 'xml import' do
        describe 'happy path' do
          it 'assigns the current user as the creator' do
            different_user = FactoryGirl.create(:admin)
            attrs = FactoryGirl.attributes_for(:batch_xml_import, creator_id: different_user.id)
            post 'create', batch: attrs
            expect(assigns[:batch].creator).to eq controller.current_user
          end

          it 'creates a batch' do
            batch_count = Batch.count
            post 'create', batch: FactoryGirl.attributes_for(:batch_xml_import)
            expect(Batch.count).to eq batch_count + 1
          end

          it 'assigns @batch' do
            post 'create', batch: FactoryGirl.attributes_for(:batch_xml_import)
            expect(assigns[:batch].class).to eq BatchXmlImport
          end

          it 'redirects to the batch edit page' do
            post 'create', batch: FactoryGirl.attributes_for(:batch_xml_import)
            expect(response).to redirect_to(edit_batch_path(assigns[:batch]))
          end
        end

        describe 'error path' do
          it 'renders :new_xml_import form' do
            post 'create', batch: { type: 'BatchXmlImport'}
            expect(response).to render_template :new_xml_import
          end
        end
      end

      describe "batch publishing" do
        it_should_behave_like 'requires a list of pids', :batch_publish
        it_should_behave_like 'batch creation happy path', BatchPublish
        it_should_behave_like 'batch run failure recovery', BatchPublish
      end

      describe "batch publishing - error path:" do
        it "redirects to previous page" do
          BatchPublish.any_instance.stub(:save) { true }
          BatchPublish.any_instance.stub(:run) { false }
          allow(controller.request).to receive(:referer) { catalog_index_path }
          post :create, batch: { pids: ['pid:1'], type: 'BatchPublish' }
          response.should redirect_to(request.referer)
        end
      end

      describe "batch purge" do
        it_should_behave_like 'requires a list of pids', :batch_purge
        it_should_behave_like 'batch creation happy path', BatchPurge
        it_should_behave_like 'batch run failure recovery', BatchPurge
      end

      describe "batch purge - error path:" do
        it "redirects to previous page" do
          BatchPurge.any_instance.stub(:save) { true }
          BatchPurge.any_instance.stub(:run) { false }
          allow(controller.request).to receive(:referer) { catalog_index_path }
          post :create, batch: { pids: ['pid:1'], type: 'BatchPurge' }
          response.should redirect_to(request.referer)
        end
      end

      describe "template updates" do
        it_should_behave_like 'requires a list of pids', :batch_template_update
        it_should_behave_like 'batch creation happy path', BatchTemplateUpdate
        it_should_behave_like 'batch run failure recovery', BatchTemplateUpdate

        def post_create(overrides={})
          BatchTemplateUpdate.any_instance.stub(:run) { true }
          post 'create', batch: FactoryGirl.attributes_for(:batch_template_update).merge(overrides)
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


    describe "GET 'edit'" do
      let(:batch) { FactoryGirl.create(:batch_template_import) }

      before do
        get :edit, id: batch.id
      end

      it 'assigns @batch' do
        expect(assigns[:batch].id).to eq batch.id
      end

      it 'should render the form' do
        response.should render_template(:edit)
      end

      it "returns http success" do
        response.should be_success
      end
    end


    describe "PATCH 'update'" do

      describe 'error path (wrong batch type)' do
        # A batch type that isn't handled in the update action
        let(:batch) { FactoryGirl.create(:batch_publish) }

        before do
          patch :update, id: batch.id
        end

        it 'redirects and displays an error message' do
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to match /Unable to handle batch request/
        end
      end

      describe 'for template import' do
        let(:batch) { FactoryGirl.create(:batch_template_import, pids: ['oldpid:123']) }
        let(:file1) { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'hello.pdf')) }
        let(:file2) { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'hello.pdf')) }

        describe 'happy path' do
          before do
            TuftsPdf.delete_all
            patch :update, id: batch.id, documents: [file1, file2], batch: {}
          end

          it_behaves_like 'an import happy path'

          it 'creates the records with the template attributes' do
            expect(TuftsPdf.count).to eq 2
            expect(TuftsPdf.first.title).to eq batch.template.title
          end

        end

        it_behaves_like 'an import error path (no documents uploaded)'
        it_behaves_like 'an import error path (wrong file format)'
        it_behaves_like 'an import error path (failed to save batch)'

        describe 'JSON request' do
          before { TuftsPdf.delete_all }
          after { TuftsPdf.delete_all }

          it_behaves_like 'a JSON import'

          describe 'error path (failed to save batch)' do
            before do
              allow(Batch).to receive(:find) { batch }
              allow(batch).to receive(:save) { false }
              @batch_error = 'Batch Error 1'
              batch.errors.add(:base, @batch_error)
              patch :update, id: batch.id, documents: [file1], format: :json
            end

            it 'returns JSON data needed by the view template' do
              json = JSON.parse(response.body)['files'].first
              expect(json['pid']).to eq TuftsPdf.first.pid
              expect(json['name']).to eq batch.template.title
              expect(json['error']).to eq [@batch_error]
            end
          end
        end  # JSON request
      end  # template import section

      describe 'for xml import' do
        let(:batch) { FactoryGirl.create(:batch_xml_import, pids: ['oldpid:123']) }
        let(:file1) { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'hello.pdf')) }
        let(:file2) { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'hello2.pdf')) }

        describe 'happy path' do
          before do
            TuftsPdf.delete_all
            patch :update, id: batch.id, documents: [file1, file2], batch: {}
          end

          it_behaves_like 'an import happy path'

        end

        it_behaves_like 'an import error path (no documents uploaded)'
        it_behaves_like 'an import error path (wrong file format)'
        it_behaves_like 'an import error path (failed to save batch)'

        context "with duplicate file upload" do
          let(:file3) { file1 }
          before do
            TuftsPdf.delete_all
            patch :update, id: batch.id, documents: [file1, file2, file3], batch: {}
          end

          it "displays a warning" do
            pending "duplicate file upload working"
            expect(flash[:alert]).to match "#{file3.original_filename} has already been uploaded"
          end

          it "doesn't save the duplicate file" do
            expect(TuftsPdf.count).to eq 2
          end
        end

        context "with a file that isn't in the metadata" do
          let(:file1) { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'tufts_WP0001.foxml.xml')) }
          before do
            TuftsPdf.delete_all
            patch :update, id: batch.id, documents: [file1], batch: {}
          end

          it "displays a warning" do
            expect(flash[:error]).to match "#{file1.original_filename} doesn't exist in the metadata file"
          end

          it "doesn't save the file" do
            expect(TuftsPdf.count).to eq 0
          end
        end

        describe 'JSON request' do
          before { TuftsPdf.delete_all }
          after { TuftsPdf.delete_all }

          it_behaves_like 'a JSON import'

          context "with duplicate file upload" do
            let(:file3) { file1 }
            before do
              TuftsPdf.delete_all
              patch :update, id: batch.id, documents: [file1, file2, file3], batch: {}, format: :json
            end

            it "displays a warning" do
              pending "duplicate file upload working"
              json = JSON.parse(response.body)['files'].first
              expect(json['warning']).to eq "#{file3.original_filename} has already been uploaded"
            end
          end

          context "with a file that isn't in the metadata" do
          let(:file1) { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'tufts_WP0001.foxml.xml')) }
            before do
              TuftsPdf.delete_all
              patch :update, id: batch.id, documents: [file1], batch: {}, format: :json
            end

            it "displays a warning" do
              json = JSON.parse(response.body)['files'].first
              expect(json['error']).to eq ["#{file1.original_filename} doesn't exist in the metadata file"]
            end

            it "displays the filename" do
              json = JSON.parse(response.body)['files'].first
              expect(json['name']).to eq file1.original_filename
            end
          end

          describe 'error path (failed to save batch)' do
            before do
              allow(Batch).to receive(:find) { batch }
              allow(batch).to receive(:save) { false }
              @batch_error = 'Batch Error 1'
              batch.errors.add(:base, @batch_error)
              patch :update, id: batch.id, documents: [file1], format: :json
            end

            it 'returns JSON data needed by the view template' do
              json = JSON.parse(response.body)['files'].first
              expect(json['pid']).to eq TuftsPdf.first.pid
              doc = Nokogiri::XML(batch.metadata_file.read)
              title = doc.at_xpath("//digitalObject[child::file/text()='#{file1.original_filename}']/*[local-name()='title']").content
              expect(json['name']).to eq title
              expect(json['error']).to eq [@batch_error]
            end
          end

        end  # JSON request
      end  # template import section
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

      describe 'with no pids (yet)' do
        before do
          @batch = FactoryGirl.create(:batch_template_import, pids: nil)
          get :show, id: @batch.id
        end

        after { @batch.delete }

        it 'gracefully sets @records_by_pid empty' do
          expect(assigns[:records_by_pid]).to eq({})
        end
      end
    end
  end
end
