require 'spec_helper'

describe GenericsController do
  describe "an admin" do
    before do
      @user = FactoryGirl.create(:admin)
      sign_in @user
      @generic = TuftsGenericObject.new(title: 'My title2')
      @generic.edit_users = [@user.email]
      @generic.save!
    end
    after do
      @generic.destroy
    end
    it "should be successful" do
      get :edit, id: @generic
      response.should be_successful
      assigns[:generic].title.should == ['My title2']
    end

    it "should update with many rows" do
      put :update, id: @generic, "generic"=>{"item_attributes"=>{"0"=>{"link"=>"link one", "mimeType"=>"mime one", "fileName"=>"file one"}, "1"=>{"link"=>"link two", "mimeType"=>"mime two", "fileName"=>"file two"}, "2"=>{"link"=>"link three", "mimeType"=>"mime three", "fileName"=>"file three"}}}

      @generic.reload.item.size.should == 3
      @generic.reload.item(2).mimeType.should == ['mime three']
      response.should redirect_to(HydraEditor::Engine.routes.url_helpers.edit_record_path(@generic))
    end
  end
end
