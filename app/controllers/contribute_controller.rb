class ContributeController < ApplicationController

  skip_before_filter :authenticate_user!, only: [:home, :license]

  def home
  end

  def license
  end

  def new
  end

  def create
  end
end
