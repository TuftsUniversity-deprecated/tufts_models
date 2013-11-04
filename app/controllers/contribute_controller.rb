class ContributeController < ApplicationController

  skip_before_filter :authenticate_user!, only: [:index, :license, :redirect]

  def index
  end

  def redirect # normal users calling '/' should be redirected to ''/contribute'
    redirect_to contributions_path
  end

  def license
  end

  def new
    authorize! :create, Contribution
    @deposit_type = DepositType.where(id: params[:deposit_type]).first
    @contribution = Contribution.new
    # Redirect the user to the selection page is the deposit type is invalid or missing
    redirect_to contributions_path unless @deposit_type
  end

  def create
    authorize! :create, Contribution
    @contribution = Contribution.new(params[:contribution])
    if @contribution.save
      flash[:notice] = "Your file has been saved!"
      redirect_to contributions_path
    else
      @deposit_type = DepositType.where(id: params[:deposit_type]).first
      render :new
    end
  end


end
