require 'spec_helper'

describe "contribute/new.html.erb", if: Tufts::Application.mira? do

  context 'with valid deposit_type' do
    let(:deposit_type) { FactoryGirl.create(:deposit_type, :deposit_view => 'generic_deposit') }

    before do
      view.stub(current_user: double(display_name: 'Frodo'))
      assign :deposit_type, deposit_type
      assign :contribution, deposit_type.contribution_class.new
      render
    end

    it 'has an input for file upload' do
      expect(rendered).to have_selector("input[type=file][name='contribution[attachment]']")
    end

    it 'has an input for title' do
      expect(rendered).to have_selector("input[name='contribution[title]']")
    end

  end

end
