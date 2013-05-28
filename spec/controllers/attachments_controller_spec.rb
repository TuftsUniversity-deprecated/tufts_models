require 'spec_helper'

describe AttachmentsController do
  describe "an admin" do
    before do
      @user = FactoryGirl.create(:admin)
      sign_in @user
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
        get :index, :record_id=>@audio.pid
        response.should be_successful
        assigns[:record].title.should == ['My title2']
      end
    end
  end
end
