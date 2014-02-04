require 'spec_helper'

describe 'Catalog routes: ' do
  let(:id) { 'tufts:T123.1.2.3' }

  it 'route to index page' do
    expect(get: 'catalog').to route_to(
      controller: 'catalog',
      action: 'index'
    )
  end

  it 'route to show page for an object' do
    expect(get: "catalog/#{id}").to route_to(
      controller: 'catalog',
      action: 'show',
      id: id
    )
  end

  it 'route to opensearch.xml' do
    expect(get: 'catalog/opensearch.xml').to route_to(
      controller: 'catalog',
      action: 'opensearch',
      format: 'xml'
    )
  end

end
