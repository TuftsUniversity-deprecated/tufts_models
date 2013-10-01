# Controller for contributor self-deposits
class SelfDepositsController < ApplicationController
  def index
    authorize! :edit, TuftsSelfDeposit

  end

  def new
    authorize! :create, TuftsSelfDeposit
    unless has_valid_type?
      render 'choose_type'
      return
    end
  end
end