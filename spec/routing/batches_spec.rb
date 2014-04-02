require 'spec_helper'

describe 'Batch routes: ' do
  it 'routes to create' do
    expect(post: 'batches').to route_to(
      controller: 'batches',
      action: 'create'
    )
  end

  it 'routes to index' do
    expect(get: 'batches').to route_to(
      controller: 'batches',
      action: 'index'
    )
  end

  it 'routes to show' do
    expect(get: 'batches/1').to route_to(
      controller: 'batches',
      action: 'show',
      id: '1'
    )
  end

  it 'routes to new_template_import' do
    expect(get: 'batches/new_template_import').to route_to(
      controller: 'batches',
      action: 'new_template_import'
    )
  end

  it 'routes to edit' do
    expect(get: 'batches/1/edit').to route_to(
      controller: 'batches',
      action: 'edit',
      id: '1'
    )
  end

  it 'routes to update' do
    expect(patch: 'batches/1').to route_to(
      controller: 'batches',
      action: 'update',
      id: '1'
    )
  end

end
