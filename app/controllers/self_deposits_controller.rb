# Controller for contributor self-deposits
class SelfDepositsController < ApplicationController
  def index
    authorize! :index, TuftsSelfDeposit
    #@self_deposits = TuftsSelfDeposit.all
  end

  def show
    @self_deposit = TuftsSelfDeposit.find(params[:id])
  end

  def new
    authorize! :create, TuftsSelfDeposit

    session[:self_deposit_params] ||= {}
    @self_deposit = TuftsSelfDeposit.new(session[:self_deposit_params])
    @self_deposit.current_step = session[:self_deposit_step]
  end

  def create
    authorize! :create, TuftsSelfDeposit

    session[:self_deposit_params].deep_merge!(params[:tufts_self_deposit]) if params[:tufts_self_deposit]
    @self_deposit = TuftsSelfDeposit.new(session[:self_deposit_params])
    @self_deposit.current_step = session[:self_deposit_step]

    if params[:back_button]
      @self_deposit.previous_step
    elsif @self_deposit.last_step?
      @self_deposit.save!
    else
      @self_deposit.next_step
    end

    session[:self_deposit_step] = @self_deposit.current_step

    if @self_deposit.new_record?
      render "new"
    else
      session[:self_deposit_step] = session[:self_deposit_params] = nil
      flash[:notice] = "Self deposit saved!"
      redirect_to action: 'show', id: @self_deposit
    end

  end

end