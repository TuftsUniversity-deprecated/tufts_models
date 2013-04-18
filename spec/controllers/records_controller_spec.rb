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
      it "should be successful" do
        get :new, :type=>'TuftsAudio'
        response.should be_successful
        response.should render_template(:new)
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
          @image = TuftsImage.new()
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
  end


  describe "a non-admin" do
    before do
      sign_in FactoryGirl.create(:user)
    end
    describe "who goes to the new page" do
      it "should not be allowed" do
        lambda { get :new }.should raise_error CanCan::AccessDenied
      end
    end
  end
end
