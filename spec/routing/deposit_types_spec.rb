require 'spec_helper'

describe 'Routes for deposit type: ' do

  it 'has an export route' do
    expect( get: 'deposit_types/export' ).to(
      route_to(controller: 'deposit_types', action: 'export')
    )
  end

end
