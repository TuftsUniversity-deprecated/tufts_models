require 'spec_helper'

describe AttachmentsController do
  describe "an admin" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
    end
    describe "editing a record" do
      let(:audio) { TuftsAudio.create!(title: 'My title2', edit_users: [user.user_key]) }
      after do
        audio.destroy
      end
      it "should be successful" do
        get :index, :record_id=>audio.pid
        response.should be_successful
        assigns[:record].title.should == 'My title2'
      end
    end
    describe "editing generic object" do
      let(:generic) { TuftsGenericObject.create!(title: 'My title2', edit_users: [user.user_key]) }
      after do
        generic.destroy
      end
      it "should be successful" do
        get :index, :record_id=>generic.pid
        response.should redirect_to edit_generic_path(generic)
      end
    end

    describe "uploading" do
      let(:pdf) { TuftsPdf.create!(title: 'My title2', edit_users: [user.user_key]) }
      after do
        pdf.destroy
      end
      describe "a pdf file to a pdf object" do
        it "should be successful" do
          file = fixture_file_upload('/local_object_store/data01/tufts/central/dca/MISS/archival_pdf/MISS.ISS.IPPI.archival.pdf','application/pdf')
          put :update, record_id: pdf, id: 'Archival.pdf', files: {'Archival.pdf' => file}, format: 'json'
          json = JSON.parse(response.body)
          json["message"].should == "Archival.pdf has been added"
          json["status"].should == "success"
          pdf.reload.audit_log.what.should == ["Content updated: Archival.pdf"]
        end
      end
      describe "a wav file to a pdf object" do
        it "should give an error saying this is the incorrect type" do
          file = fixture_file_upload('/local_object_store/data01/tufts/central/dca/MISS/archival_sound/MISS.ISS.IPPI.archival.wav','audio/wav')
          put :update, record_id: pdf, id: 'Archival.pdf', files: {'Archival.pdf' => file}, format: 'json'
          json = JSON.parse(response.body)
          json["message"].should == "You provided a audio/wav file, which is not a valid type for Archival.pdf"
          json["status"].should == "error"
        end
      end
    end
  end
end
