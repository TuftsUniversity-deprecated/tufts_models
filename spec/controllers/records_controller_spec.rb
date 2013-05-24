require 'spec_helper'

describe RecordsController do
  before do
    @routes = HydraEditor::Engine.routes 
  end
  describe "an admin" do
    before do
      @user = FactoryGirl.create(:admin)
      sign_in @user
    end
    describe "who goes to the new page" do
      it "should be successful" do
        get :new
        response.should be_successful
        response.should render_template(:choose_type)
      end
      it "should be successful without a pid" do
        get :new, :type=>'TuftsAudio'
        response.should be_successful
        response.should render_template(:new)
        assigns[:record].should be_kind_of TuftsAudio
        assigns[:record].should_not be_new_object
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
          response.should be_successful
          response.should render_template(:new)
          assigns[:record].should be_kind_of TuftsAudio
          assigns[:record].should_not be_new_object
          assigns[:record].pid.should == 'tufts:123.1231'
        end
      end
      it "should be an error with an invalid pid" do
        get :new, :type=>'TuftsAudio', :pid => '123.1231'
        response.should be_successful
        response.should render_template(:choose_type)
        flash[:error].should == "You have specified an invalid pid. A valid pid must contain a colin (i.e. tufts:1231)"
      end
    end

    describe "creating a new record" do
      it "should be successful" do
        post :create, :type=>'TuftsAudio', :tufts_audio=>{:title=>"My title"}
        response.should redirect_to("/catalog/#{assigns[:record].pid}") 
        assigns[:record].title.should == ['My title']
      end
    end

    describe "editing a record" do
      before do
        @audio = TuftsAudio.new(title: 'My title2')
        @audio.edit_users = [@user.email]
        @audio.save!
      end
      after do
        @audio.destroy
      end
      it "should be successful" do
        get :edit, :id=>@audio.pid
        response.should be_successful
        assigns[:record].title.should == ['My title2']
      end
    end

    describe "updating a record" do
      describe "with an audio" do
        before do
          @audio = TuftsAudio.new(title: 'My title2')
          @audio.edit_users = [@user.email]
          @audio.save!
        end
        after do
          @audio.destroy
        end
        it "should be successful" do
          put :update, :id=>@audio, :tufts_audio=>{:title=>"My title 3"}
          response.should redirect_to("/catalog/#{assigns[:record].pid}") 
          assigns[:record].title.should == ['My title 3']
        end
        it "should update external datastream paths" do
          put :update, :id=>@audio, :tufts_audio=>{:datastreams=>{"ACCESS_MP3"=>"http://example.com/access.mp3", "ARCHIVAL_SOUND"=>"http://example.com/archival.wav"} }
          response.should redirect_to("/catalog/#{assigns[:record].pid}") 
          assigns[:record].datastreams['ACCESS_MP3'].dsLocation.should == 'http://example.com/access.mp3'
          assigns[:record].datastreams['ARCHIVAL_SOUND'].dsLocation.should == 'http://example.com/archival.wav'
        end
      end
      
      describe "with an image" do
        before do
          @image = TuftsImage.new(title: "test image")
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
        @routes = Tufts::Application.routes 
        @audio = TuftsAudio.new(title: 'My title2')
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
        @audio = TuftsAudio.new(title: 'My title2')
        @audio.edit_users = [@user.email]
        @audio.save!
      end
      it "should be successful with a pid" do
        delete :destroy, :id=>@audio
        response.should redirect_to(Tufts::Application.routes.url_helpers.root_path)
        TuftsAudio.exists?(@audio.pid).should be_false
      end
    end
  end


  describe "a non-admin" do
    before do
      sign_in FactoryGirl.create(:user)
    end
    describe "who goes to the new page" do
      it "should not be allowed" do
        get :new
        response.should redirect_to( Tufts::Application.routes.url_helpers.root_path)
        flash[:alert].should == "You are not authorized to access this page."
      end
    end
    describe "who goes to the edit page" do
      before do
        @audio = TuftsAudio.create!(title: 'My title2')
      end
      after do
        @audio.destroy
      end
      it "should not be allowed" do
        get :edit, id: @audio
        response.should redirect_to( Tufts::Application.routes.url_helpers.catalog_path(@audio))
        flash[:alert].should == "You do not have sufficient privileges to edit this document."
      end
    end
  end
end
