require 'spec_helper'

describe 'shared/_header_navbar.html.erb' do
  before do
    view.stub search_action_url: 'http://test.host/',
            search_field_options_for_select: ''
    stub_template '_user_util_links.html.erb' => ''
  end

  it 'displays a search box under normal circumstances' do
    render
    expect(rendered).to render_template(partial: '_search_form')
  end

  it 'suppresses search box for contribute controller' do
    view.stub controller_name: 'contribute'
    render
    expect(rendered).not_to render_template(partial: '_search_form')
  end

  it 'suppresses search box for templates controller' do
    view.stub controller_name: 'templates'
    render
    expect(rendered).not_to render_template(partial: '_search_form')
  end

  it 'suppresses search box for records controller' do
    view.stub controller_name: 'records'
    render
    expect(rendered).not_to render_template(partial: '_search_form')
  end

end