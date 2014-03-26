require 'spec_helper'

describe 'Records routes:' do
  it 'routes to review' do
    expect(put: 'records/1/review').to route_to(
      controller: 'records',
      action: 'review',
      id: '1'
    )
  end
end
