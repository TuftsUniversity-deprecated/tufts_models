require 'spec_helper'

describe RecordsController do

  describe "an admin" do
    before do
      @user = FactoryGirl.create(:admin)
      sign_in @user
    end

    describe 'reviews a record - happy path:' do
      before do
        @record = FactoryGirl.create(:tufts_pdf)
        put :review, id: @record
      end
      after { @record.delete }

      it 'assigns @record' do
        expect(assigns(:record)).to eq @record
      end

      it 'redirects to the record show page' do
        response.should redirect_to catalog_path(@record)
      end

      it 'marks the record as reviewed' do
        expect(@record.reload.reviewed?).to be_true
      end

      it 'sets the flash' do
        expect(flash[:notice]).to eq "\"#{@record.title}\" has been marked as reviewed."
      end
    end

    describe 'reviews a record - when it fails to save:' do
      before do
        @record = FactoryGirl.create(:tufts_pdf)
        TuftsPdf.any_instance.should_receive(:save) { false }
        put :review, id: @record
      end
      after { @record.delete }

      it 'sets the flash' do
        expect(flash[:error]).to eq "Unable to mark \"#{@record.title}\" as reviewed."
      end
    end

    describe "reviews a record - when it's not a reviewable record :" do
      before do
        @record = FactoryGirl.create(:tufts_template)
        put :review, id: @record
      end
      after { @record.delete }

      it 'does not mark the record as reviewed' do
        expect(flash[:error]).to eq "Unable to mark \"#{@record.title}\" as reviewed."
      end
    end

    describe "who goes to the new page" do
      before { @routes = HydraEditor::Engine.routes }

      it "should be successful" do
        get :new
        response.should be_successful
        response.should render_template(:choose_type)
      end

      it "should be successful without a pid" do
        get :new, :type=>'TuftsAudio'
        assigns[:record].should be_kind_of TuftsAudio
        assigns[:record].should_not be_new_object
        response.should redirect_to Tufts::Application.routes.url_helpers.record_attachments_path(assigns[:record]) 
      end

      describe 'with type TuftsTemplate' do
        before { get :new, :type=>'TuftsTemplate' }

        it 'creates a new template' do
          assigns[:record].should be_kind_of TuftsTemplate
        end

        it 'redirects to allow you to edit the new template' do
          response.should redirect_to HydraEditor::Engine.routes.url_helpers.edit_record_path(assigns[:record])
        end
      end

      describe "with a pid" do
        before do
          begin
            a = TuftsAudio.find('tufts:123.1231')
            a.destroy
          rescue ActiveFedora::ObjectNotFoundError
          end
        end
        it "should be successful with a pid" do
          get :new, :type=>'TuftsAudio', :pid=>'tufts:123.1231'
          assigns[:record].should be_kind_of TuftsAudio
          assigns[:record].should_not be_new_object
          response.should redirect_to Tufts::Application.routes.url_helpers.record_attachments_path(assigns[:record]) 
          assigns[:record].pid.should == 'tufts:123.1231'
        end
      end

      describe "with the pid of an existing object" do
        let(:record) { TuftsAudio.create(title: "existing", displays: ['dl']) }
        it "should redirect to the edit page and give a warning" do
          get :new, :type=>'TuftsAudio', :pid=>record.id
          response.should redirect_to HydraEditor::Engine.routes.url_helpers.edit_record_path(record.id)
          flash[:alert].should == "A record with the pid \"#{record.id}\" already exists."
        end
      end

      it "should be an error with an invalid pid" do
        get :new, :type=>'TuftsAudio', :pid => '123.1231'
        response.should be_successful
        response.should render_template(:choose_type)
        flash[:error].should == "You have specified an invalid pid. A valid pid must contain a colon (i.e. tufts:1231)"
      end
    end

    describe "creating a new record" do
      before { @routes = HydraEditor::Engine.routes }

      it "should be successful" do
        post :create, :type=>'TuftsAudio', :tufts_audio=>{:title=>"My title", displays: ['dl']}
        response.should redirect_to("/catalog/#{assigns[:record].pid}") 
        assigns[:record].title.should == 'My title'
      end
    end

    describe "editing a record" do
      before do
        @routes = HydraEditor::Engine.routes
        @audio = TuftsAudio.new(title: 'My title2', displays: ['dl'])
        @audio.edit_users = [@user.email]
        @audio.save!
      end
      after do
        @audio.destroy
      end
      it "should be successful" do
        get :edit, :id=>@audio.pid
        response.should be_successful
        assigns[:record].title.should == 'My title2'
      end
    end

    describe 'cancel' do
      describe "on an object with no existing versions of DCA-META" do
        before do
          @audio = TuftsAudio.new()
          @audio.edit_users = [@user.email]
          @audio.save(validate: false)
        end
        it "should remove the record" do
          expect { delete :cancel, id: @audio}.to change{TuftsAudio.count}.by(-1)
        end
      end

      describe "on an object with an existing version of DCA-META" do
        before do
          @audio = TuftsAudio.new(title: "My title2", displays: ['dl'])
          @audio.edit_users = [@user.email]
          @audio.save!
        end
        it "should not remove the record" do
          expect { delete :cancel, id: @audio}.to_not change{TuftsAudio.count}
        end
      end
      it "should not remove the record if there are no existing versions of the dca-META" do
      end
    end

    describe "updating a record" do
      before { @routes = HydraEditor::Engine.routes }

      describe "with an audio" do
        before do
          @audio = TuftsAudio.new(title: 'My title2', displays: ['dl'])
          @audio.edit_users = [@user.email]
          @audio.save!
        end
        after do
          @audio.destroy
        end
        it "should be successful" do
          put :update, :id=>@audio, :tufts_audio=>{:title=>"My title 3"}
          response.should redirect_to("/catalog/#{assigns[:record].pid}") 
          assigns[:record].title.should == 'My title 3'
          assigns[:record].reload.audit_log.what.should == ['Metadata updated rightsMetadata, DCA-META, DCA-ADMIN']
        end
        it "should update external datastream paths" do
          put :update, :id=>@audio, :tufts_audio=>{:datastreams=>{"ACCESS_MP3"=>"http://example.com/access.mp3", "ARCHIVAL_SOUND"=>"http://example.com/archival.wav"} }
          response.should redirect_to("/catalog/#{assigns[:record].pid}") 
          assigns[:record].datastreams['ACCESS_MP3'].dsLocation.should == 'http://example.com/access.mp3'
          assigns[:record].datastreams['ARCHIVAL_SOUND'].dsLocation.should == 'http://example.com/archival.wav'
        end
        it 'should update the collection id' do
          put :update, :id=>@audio, :tufts_audio=>{:stored_collection_id=>["updated_id"]}
          assigns[:record].stored_collection_id.should == 'updated_id'
        end
      end
      
      describe "with an image" do
        before do
          @image = TuftsImage.new(title: "test image", displays: ['dl'])
          @image.edit_users = [@user.email]
          @image.save!
        end
        after do
          @image.destroy
        end
        it "should update external datastream paths" do
          put :update, :id=>@image, :tufts_image=>{:datastreams=>{"Advanced.jpg"=>"http://example.com/advanced.jpg", "Basic.jpg"=>"http://example.com/basic.jpg", "Archival.tif"=>"http://example.com/archival.tif", "Thumbnail.png"=>"http://example.com/thumb.png"} }
          response.should redirect_to("/catalog/#{assigns[:record].pid}") 
          assigns[:record].datastreams['Advanced.jpg'].dsLocation.should == 'http://example.com/advanced.jpg'
          assigns[:record].datastreams['Basic.jpg'].dsLocation.should == 'http://example.com/basic.jpg'
          assigns[:record].datastreams['Archival.tif'].dsLocation.should == 'http://example.com/archival.tif'
          assigns[:record].datastreams['Thumbnail.png'].dsLocation.should == 'http://example.com/thumb.png'

        end
      end
    end

    describe "publish a record" do
      before do
        @audio = TuftsAudio.new(title: 'My title2', displays: ['dl'])
        @audio.edit_users = [@user.email]
        @audio.save!
      end
      after do
        @audio.destroy
      end
      it "should be successful" do
        TuftsAudio.any_instance.should_receive(:push_to_production!)
        post :publish, :id=>@audio
        response.should redirect_to("/catalog/#{assigns[:record].pid}") 
        flash[:notice].should == '"My title2" has been pushed to production'
      end
    end

    describe "destroying a record" do
      before do
        @audio = TuftsAudio.new(title: 'My title2', displays: ['dl'])
        @audio.edit_users = [@user.email]
        @audio.save!
      end
      it "should be successful with a pid" do
        delete :destroy, :id=>@audio
        response.should redirect_to(Tufts::Application.routes.url_helpers.root_path)
        @audio.reload.state.should == 'D' 
      end
    end
  end


  describe "a non-admin" do
    before do
      sign_in FactoryGirl.create(:user)
    end

    describe "who goes to the new page" do
      before { @routes = HydraEditor::Engine.routes }

      it "should not be allowed" do
        get :new
        response.status.should == 302
        response.should redirect_to Tufts::Application.routes.url_helpers.root_path
        flash[:alert].should =~ /You are not authorized to access this page/i
      end
    end

    describe "who goes to the edit page" do
      before do
        @routes = HydraEditor::Engine.routes
        @audio = TuftsAudio.create!(title: 'My title2', displays: ['dl'])
      end
      after do
        @audio.destroy
      end
      it "should not be allowed" do
        get :edit, id: @audio
        response.status.should == 302
        response.should redirect_to Tufts::Application.routes.url_helpers.contributions_path
        flash[:alert].should =~ /You do not have sufficient privileges to edit this document/i
      end
    end

    describe 'reviews a record' do
      before do
        @record = FactoryGirl.create(:tufts_pdf)
        put :review, id: @record
      end
      after { @record.delete }

      it 'should not be allowed' do
        response.status.should == 302
        response.should redirect_to Tufts::Application.routes.url_helpers.root_path
        flash[:alert].should =~ /You are not authorized to access this page/i
      end
    end
  end

end
