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
  end

  def create
  end
end
