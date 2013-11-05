require 'spec_helper'

describe ContributeController do

  describe "for a not-signed in user" do
    describe "new" do
      it "should redirect to sign in" do
        get :new
        response.should redirect_to new_user_session_path
      end
    end
    describe "create" do
      it "should redirect to sign in" do
        post :create
        response.should redirect_to new_user_session_path
      end
    end
  end


  describe "for a signed in user" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    describe "GET '/'" do
      it "returns http success" do
        get :index 
        response.should be_success
      end
    end

    describe "GET 'license'" do
      it "returns http success" do
        get 'license'
        response.should be_success
      end
    end

    describe "GET 'new'" do
      it "redirects to contribute home when no deposit type is specified" do
        get 'new'
        response.should redirect_to contributions_path
      end

      describe 'with valid deposit_type' do
        before :all do
          @deposit_type = FactoryGirl.create(:deposit_type, :display_name => 'Test Option', :deposit_view => 'generic_deposit')
        end

        after :all do
          @deposit_type.destroy
        end
        render_views

        it 'should render the correct template' do
          get 'new', {deposit_type: @deposit_type.id}
          response.should render_template('contribute/deposit_view/_generic_deposit')
        end

        it 'should include a title input'
        it 'should include a file upload input'

        it 'should include deposit license text' do
          get 'new', {deposit_type: @deposit_type.id}
          response.body.should have_content @deposit_type.deposit_agreement
        end

        it 'sets deposit_type and contribution' do
          get :new, { deposit_type: @deposit_type }
          assigns(:deposit_type).should == @deposit_type
          assigns(:contribution).should_not be_nil
        end
      end
    end

    describe "GET 'redirect'" do
      it "redirects to contribute" do
        get 'redirect'
        response.should redirect_to contributions_path
      end
    end

    describe "POST 'create'" do
      it "redirects when no deposit type is specified" do
        post :create, contribution: { title: 'Sample', abstract: 'Description', creator: user.user_key }
        response.should redirect_to contributions_path
      end

      describe 'with valid deposit_type' do
        before :all do
          @deposit_type = FactoryGirl.create(:deposit_type)
        end
        after :all do
          @deposit_type.destroy
        end

        it 'succeeds and stores file attachments' do
          expected_count = TuftsPdf.count + 1
          file = fixture_file_upload('/local_object_store/data01/tufts/central/dca/MISS/archival_pdf/MISS.ISS.IPPI.archival.pdf','application/pdf')
          post :create, contribution: {title: 'Sample', abstract: 'Description of uploaded file goes here', creator: user.user_key, attachment: file}, deposit_type: @deposit_type
          response.should redirect_to contributions_path
          flash[:notice].should == 'Your file has been saved!'
          assigns(:deposit_type).should == @deposit_type
          TuftsPdf.count.should == expected_count
          contribution = TuftsPdf.find(assigns[:contribution].tufts_pdf.pid)
          contribution.datastreams['Archival.pdf'].dsLocation.should_not be_nil
          contribution.datastreams['Archival.pdf'].mimeType.should == 'application/pdf'
          contribution.license.should == [@deposit_type.license_name]
        end

        it 'should require a file attachments' do
          post :create, contribution: {title: 'Sample', abstract: 'Description of uploaded file goes here', creator: user.user_key}, deposit_type: @deposit_type
          response.should render_template('new')
        end
      end
    end
  end

end
