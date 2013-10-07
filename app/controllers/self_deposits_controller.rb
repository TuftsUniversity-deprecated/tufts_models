# Controller for contributor self-deposits
class SelfDepositsController < ApplicationController
  def index
    authorize! :index, TuftsSelfDeposit
    render :index
  end

  def new
    authorize! :create, TuftsSelfDeposit

  end

  def create
    authorize! :create, TuftsSelfDeposit

    render text: params[:tufts_self_deposit].inspect
    @self_deposit = TuftsSelfDeposit.new(params[:tufts_self_deposit])
    @self_deposit.save!
    #redirect_to @self_deposit
  end

  private
  def tufts_pdf

  end

end