require 'spec_helper'

describe 'deposit_types/index.html.erb' do
  before :all do
    deposit_type_options = ['Option #1', 'Another Option','The last option']
    deposit_type_options.each do |name|
      FactoryGirl.create(:deposit_type, display_name: name)
    end
    @deposit_types = DepositType.all
    assign :deposit_types, @deposit_types
  end

  after :all do
    @deposit_types.each {|dt| dt.destroy}
  end

  it 'have links for each deposit type' do
    render
    @deposit_types.each do |dt|
      rendered.should have_selector("a[href='#{deposit_type_path(dt)}']", text: dt.display_name)
    end
    rendered.should have_selector 'td[class="deposit_view"]', count: @deposit_types.count
    rendered.should have_selector 'td[class="deposit_agreement"]', count: @deposit_types.count
    rendered.should have_selector 'td[class="license_name"]', count: @deposit_types.count

  end

  it 'has a link to create new deposit types' do
    render
    assert_select "a[href=?]", new_deposit_type_path
  end

  it 'has a link to export deposit types' do
    render
    assert_select "a[href=?]", export_deposit_types_path
  end

end