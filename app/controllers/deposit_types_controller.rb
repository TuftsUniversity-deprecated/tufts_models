class DepositTypesController < ApplicationController

  before_filter :check_for_cancel, :only => [:create, :update]

  def index
    @deposit_types = TuftsDepositType.all
  end

  def new
  end

  def show
    @deposit_type = TuftsDepositType.find(params[:id])
  end

  def destroy
    @deposit_type = TuftsDepositType.find(params[:id])
    @deposit_type.destroy

    redirect_to deposit_types_path
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

  def update
    @deposit_type = TuftsDepositType.find(params[:id])

    if @deposit_type.update_attributes!(params[:deposit_type].permit(:display_name, :deposit_agreement))
      redirect_to deposit_type_path(@deposit_type), :notice => 'Record was successfully updated.'
    else
      render 'edit'
    end
  end

  private
  def deposit_type_params
    params.require(:deposit_type).permit(:display_name, :deposit_agreement)
  end

  def check_for_cancel
    unless params[:cancel].blank?
      redirect_to deposit_types_path
    end
  end
end
