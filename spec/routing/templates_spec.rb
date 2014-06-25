require 'spec_helper'

describe 'Template routes:', if: Tufts::Application.mira? do
  it 'index route' do
    expect(get: 'templates').to route_to(
      controller: 'templates',
      action: 'index'
    )
  end
end
