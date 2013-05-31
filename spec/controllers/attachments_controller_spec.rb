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
        @audio.edit_users = [@user.user_key]
        @audio.save!
      end
      after do
        @audio.destroy
      end
      it "should be successful" do
        get :index, :record_id=>@audio.pid
        response.should be_successful
        assigns[:record].title.should == 'My title2'
      end
    end
    describe "editing generic object" do
      before do
        @generic = TuftsGenericObject.new(title: 'My title2')
        @generic.edit_users = [@user.user_key]
        @generic.save!
      end
      after do
        @generic.destroy
      end
      it "should be successful" do
        get :index, :record_id=>@generic.pid
        response.should redirect_to edit_generic_path(@generic)
      end
    end

    describe "uploading" do
      before do
        @pdf = TuftsPdf.new(title: 'My title2')
        @pdf.edit_users = [@user.user_key]
        @pdf.save!
      end
      after do
        @pdf.destroy
      end
      describe "a pdf file to a pdf object" do
        it "should be successful" do
          file = fixture_file_upload('/local_object_store/data01/tufts/central/dca/MISS/archival_pdf/MISS.ISS.IPPI.archival.pdf','application/pdf')
          put :update, record_id: @pdf, id: 'Archival.pdf', files: {'Archival.pdf' => file}
          flash[:alert].should be_nil
        end
      end
      describe "a wav file to a pdf object" do
        it "should give an error saying this is the incorrect type" do
          file = fixture_file_upload('/local_object_store/data01/tufts/central/dca/MISS/archival_sound/MISS.ISS.IPPI.archival.wav','audio/wav')
          put :update, record_id: @pdf, id: 'Archival.pdf', files: {'Archival.pdf' => file}
          flash[:alert].should == ["You provided a audio/wav file, which is not a valid type for Archival.pdf"]
        end
      end
    end
  end
end
