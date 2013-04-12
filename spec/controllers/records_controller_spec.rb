require 'spec_helper'

describe RecordsController do
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
        response.should redirect_to(catalog_path(assigns[:record])) 
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
        response.should redirect_to(catalog_path(assigns[:record])) 
        assigns[:record].title.should == ['My title 3']
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
