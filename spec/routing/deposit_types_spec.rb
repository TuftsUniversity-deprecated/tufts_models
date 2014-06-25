require 'spec_helper'

describe 'Routes for deposit type:', if: Tufts::Application.mira? do

  it 'has an export route' do
    expect( get: 'deposit_types/export' ).to(
      route_to(controller: 'deposit_types', action: 'export')
    )
  end

end
