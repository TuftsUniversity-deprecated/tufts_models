require 'spec_helper'

describe 'Batch routes: ' do
  it 'routes to create' do
    expect(post: 'batches').to route_to(
      controller: 'batches',
      action: 'create'
    )
  end

  it 'routes to show' do
    expect(get: 'batches/1').to route_to(
      controller: 'batches',
      action: 'show',
      id: '1'
    )
  end
end
