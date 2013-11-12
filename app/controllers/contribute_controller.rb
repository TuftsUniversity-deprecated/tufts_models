class ContributeController < ApplicationController

  skip_before_filter :authenticate_user!, only: [:index, :license, :redirect]
  before_filter :load_deposit_type, only: [:new, :create]

  def index
  end

  def redirect # normal users calling '/' should be redirected to ''/contribute'
    redirect_to contributions_path
  end

  def license
  end

  def new
    authorize! :create, Contribution
    @contribution = @deposit_type.contribution_class.new
  end

  def create
    authorize! :create, Contribution
    @contribution = @deposit_type.contribution_class.new(params[:contribution].merge(:deposit_type => @deposit_type))

    if @contribution.save
      flash[:notice] = "Your file has been saved!"
      redirect_to contributions_path
    else
      render :new
    end
  end

protected

  def load_deposit_type
    @deposit_type = DepositType.where(id: params[:deposit_type]).first
    # Redirect the user to the selection page if the deposit type is invalid or missing
    redirect_to contributions_path unless @deposit_type
  end

end
