require 'spec_helper'

describe 'Advanced Search routes: ' do
  let(:id) { 'subject_sim' }

  it 'route to index page' do
    expect(get: 'advanced').to route_to(
      controller: 'advanced',
      action: 'index'
    )
  end

  it 'route to facet list' do
    expect(get: "advanced/facet?id=#{id}").to route_to(
      controller: 'advanced',
      action: 'facet',
      id: id
    )
  end
end
