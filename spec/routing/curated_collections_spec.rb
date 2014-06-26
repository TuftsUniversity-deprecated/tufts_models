require 'spec_helper'

describe 'CuratedCollection routes:', if: Tufts::Application.til? do
  it 'routes to create' do
    expect(post: 'curated_collections').to route_to(
      controller: 'curated_collections',
      action: 'create'
    )
  end

  it 'routes to show' do
    expect(get: 'curated_collections/changeme:77').to route_to( controller: 'curated_collections', action: 'show', id: 'changeme:77')
  end

  it 'routes to append_to' do
    expect(patch: 'curated_collections/1/append_to').to route_to(
      controller: 'curated_collections',
      action: 'append_to',
      id: '1'
    )
  end
end
