require 'spec_helper'
require 'import_export/deposit_type_exporter'

describe DepositTypesController do
  before :each do
    DepositType.destroy_all
    @dt = FactoryGirl.create(:deposit_type, display_name: 'DT')
  end

  context 'a non-admin user' do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    def assert_access_denied(http_command, action, opts={})
      send(http_command, action, opts)
      flash[:alert].should =~ /You are not authorized/
      response.should redirect_to(root_url)
    end

    it 'denies access' do
      assert_access_denied :get, :index
      assert_access_denied :get, :export
      assert_access_denied :get, :new
      assert_access_denied :post, :create, :deposit_type => @dt.attributes
      assert_access_denied :get, :show, id: @dt.id
      assert_access_denied :delete, :destroy, id: @dt.id
      assert_access_denied :put, :update, id: @dt.id
      # Edit is tested below, since it has different behavior
    end

    it 'denies access to edit deposit types' do
      get :edit, id: @dt.id
      flash[:alert].should =~ /You do not have sufficient privilege/
      response.should redirect_to(contributions_path)
    end
  end


  context 'an admin user' do
    before do
      @admin = FactoryGirl.create(:admin)
      sign_in @admin
    end

    describe 'get index' do
      it 'succeeds' do
        get :index
        response.should be_successful
        response.should render_template(:index)
        assigns(:deposit_types).should == [@dt]
      end
    end

    describe 'get export' do
      it 'succeeds' do
        DepositTypeExporter.any_instance.should_receive(:export_to_csv)
        get :export
        response.should redirect_to(deposit_types_path)
        flash[:notice].should =~ /exported the deposit types to: #{File.join(DepositTypeExporter::DEFAULT_EXPORT_DIR)}/
      end
    end

    describe 'get new' do
      it 'succeeds' do
        get :new
        assigns(:deposit_type).should_not be_nil
        response.should render_template(:new)
      end
    end

    describe 'get show' do
      it 'succeeds' do
        get :show, id: @dt.id
        response.should be_successful
        response.should render_template(:show)
        assigns(:deposit_type).should == @dt
      end
    end

    describe 'destroy' do
      it 'succeeds' do
        dt2 = FactoryGirl.create(:deposit_type, display_name: 'some other type')
        DepositType.count.should == 2

        delete :destroy, id: dt2.id
        DepositType.count.should == 1
        DepositType.all.should == [@dt]
      end
    end

    describe 'create' do
      it 'succeeds' do
        DepositType.count.should == 1
        post :create, deposit_type: { display_name: 'New Type', deposit_view: 'generic_deposit' }
        DepositType.count.should == 2
        new_type = DepositType.where(display_name: 'New Type').first
        response.should redirect_to(deposit_type_path(new_type))
        assigns(:deposit_type).should == new_type
      end
    end

    describe 'create with bad inputs' do
      it 'renders the form' do
        # Make it fail to validate:
        DepositType.any_instance.stub(:valid?).and_return(false)
        post :create, deposit_type: { display_name: 'New Type' }
        response.should render_template(:new)
        DepositType.count.should == 1
        assigns(:deposit_type).should_not be_nil
      end
    end

    describe 'edit' do
      it 'succeeds' do
        get :edit, id: @dt.id
        assigns(:deposit_type).should == @dt
        response.should render_template(:edit)
      end
    end

    describe 'update' do
      it 'succeeds' do
        @dt.display_name.should == 'DT'
        put :update, id: @dt.id, deposit_type: { display_name: 'New Name' }
        @dt.reload
        @dt.display_name.should == 'New Name'
        assigns(:deposit_type).should == @dt
        response.should redirect_to(deposit_type_path(@dt))
      end
    end

    describe 'update with bad inputs' do
      it 'renders the form' do
        # Make it fail to validate:
        DepositType.any_instance.stub(:valid?).and_return(false)
        @dt.display_name.should == 'DT'

        put :update, id: @dt.id, deposit_type: { display_name: 'New Name' }
        @dt.reload
        @dt.display_name.should == 'DT'
        assigns(:deposit_type).should == @dt
        response.should render_template(:edit)
      end
    end

  end

end
