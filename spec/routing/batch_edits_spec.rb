require 'spec_helper'

describe 'Batch Edits routes: ' do
  let(:id) { 'tufts:T123.1.2.3' }

  it 'routes to batch edits' do
    expect(get: 'batch_edits/edit').to route_to(
      controller: 'batch_edits',
      action: 'edit'
    )
  end
end
