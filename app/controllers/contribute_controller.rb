class ContributeController < ApplicationController

  skip_before_filter :authenticate_user!, only: [:home, :license, :redirect]

  def home
  end

  def redirect # normal users calling '/' should be redirected to ''/contribute'
    redirect_to action: 'home'
  end

  def license
  end

  def new
    @deposit_type = DepositType.where(id: params[:type]).first

    # Redirect the user to the selection page is the deposit type is invalid or missing
    redirect_to action: 'home' if @deposit_type.nil?

  end

  def create
    redirect_to action: 'new', type: params[:deposit_type]
  end
end
