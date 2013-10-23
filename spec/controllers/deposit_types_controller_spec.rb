require 'spec_helper'
require 'import_export/deposit_type_exporter'

describe DepositTypesController do

  context 'a non-admin user' do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    def self.assert_access_denied(http_command, action)
      it "access denied for #{action}" do
        send(http_command, action)
        flash[:alert].should =~ /You are not authorized/
        response.should redirect_to(root_url)
      end
    end

    assert_access_denied :get, :index
    assert_access_denied :get, :export

    # TODO : Needs more tests!
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
        assigns(:deposit_types).should == []
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

    # TODO : Needs more tests!
  end

end
