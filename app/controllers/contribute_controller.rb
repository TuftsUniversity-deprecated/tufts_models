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
    @contribution = Contribution.new
  end

  def create
    authorize! :create, Contribution
    @contribution = Contribution.new(params[:contribution])
    insert_license_data

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

  def insert_license_data
    @contribution.license = Array(@contribution.license)
    @contribution.license << @deposit_type.license_name
  end

end
