class DepositTypesController < ApplicationController

  def index
    @deposit_types = TuftsDepositType.all
  end

  def new
  end

  def show
    @deposit_type = TuftsDepositType.find(params[:id])
  end

  def create
    @deposit_type = TuftsDepositType.new(deposit_type_params)

    @deposit_type.save!
    puts @deposit_type.inspect
    redirect_to deposit_type_path(@deposit_type)
  end

  def edit
    @deposit_type = TuftsDepositType.find(params[:id])
  end

  private
  def deposit_type_params
    params.require(:deposit_type).permit(:display_name, :deposit_agreement)
  end
end
