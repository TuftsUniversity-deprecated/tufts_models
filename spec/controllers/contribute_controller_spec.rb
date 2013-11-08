require 'spec_helper'

describe ContributeController do

  before do
    TuftsPdf.destroy_all
  end

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
        post :create, contribution: { title: 'Sample', description: 'Description', creator: user.display_name }
        response.should redirect_to contributions_path
      end

      describe 'with valid deposit_type' do
        let(:deposit_type) { FactoryGirl.create(:deposit_type) }
        let(:file) { fixture_file_upload('/local_object_store/data01/tufts/central/dca/MISS/archival_pdf/MISS.ISS.IPPI.archival.pdf','application/pdf') }

        it 'succeeds and stores file attachments' do
          expect {
            post :create, contribution: {title: 'Sample', description: 'Description goes here', 
                                         creator: user.display_name, attachment: file},
                          deposit_type: deposit_type
            response.should redirect_to contributions_path
            flash[:notice].should == 'Your file has been saved!'
            assigns(:deposit_type).should == deposit_type
            contribution = TuftsPdf.find(assigns[:contribution].tufts_pdf.pid)
            contribution.datastreams['Archival.pdf'].dsLocation.should_not be_nil
            contribution.datastreams['Archival.pdf'].mimeType.should == 'application/pdf'
            contribution.license.should == [deposit_type.license_name]
          }.to change { TuftsPdf.count }.by(1)
        end

        it 'should automatically populate static fields' do
          post :create, contribution: {title: 'Sample', description: 'User supplied brief description',
                                       creator: 'John Doe', attachment: file},
               deposit_type: deposit_type
          contribution = TuftsPdf.find(assigns[:contribution].tufts_pdf.pid)
          expect(contribution.steward).to eq ['dca']
          expect(contribution.displays).to eq ['dl']
          expect(contribution.publisher).to eq ['Tufts University. Digital Collections and Archives.']
          expect(contribution.rights).to eq ['http://dca.tufts.edu/ua/access/rights-creator.html']
          expect(contribution.format).to eq ['application/pdf']
        end

        it "should list deposit_method as self deposit" do
          now = Time.now
          Time.stub(:now).and_return(now)
          post :create, contribution: {title: 'Sample', description: 'Description of goes here',
                                        creator: 'Mickey Mouse', attachment: file},
                         deposit_type: deposit_type
          contribution = TuftsPdf.find(assigns[:contribution].tufts_pdf.pid)
          expect(contribution.note.first).to eq "Mickey Mouse self-deposited on #{now.strftime('%Y-%m-%d at %H:%M:%S %Z')} using the Deposit Form for the Tufts Digital Library"
          expect(contribution.date_available).to eq [now.to_s]
          expect(contribution.date_submitted).to eq [now.to_s]
          expect(contribution.createdby).to eq Contribution::SELFDEP
       end

        it 'should require a file attachments' do
          post :create, contribution: {title: 'Sample', description: 'Description of uploaded file goes here', creator: user.display_name}, deposit_type: deposit_type
          response.should render_template('new')
        end
      end
    end
  end

end
