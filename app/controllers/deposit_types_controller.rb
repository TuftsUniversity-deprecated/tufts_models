class DepositTypesController < ApplicationController

  def index
    authorize! :read, DepositType
    @deposit_types = DepositType.accessible_by(current_ability)
  end

  def export
    authorize! :export, DepositType
    require 'import_export/deposit_type_exporter'
    exporter = DepositTypeExporter.new
    exporter.export_to_csv
    export_file = File.join(exporter.export_dir, exporter.filename)
    flash[:notice] = "You have successfully exported the deposit types to: #{export_file}"
    redirect_to deposit_types_path
  end

  def new
  end

  def show
    @deposit_type = DepositType.find(params[:id])
  end

  def destroy
    @deposit_type = DepositType.find(params[:id])
    @deposit_type.destroy

    redirect_to deposit_types_path
  end

  def create
    @deposit_type = DepositType.new(deposit_type_params)

    @deposit_type.save!
    puts @deposit_type.inspect
    redirect_to deposit_type_path(@deposit_type)
  end

  def edit
    @deposit_type = DepositType.find(params[:id])
  end

  def update
    @deposit_type = DepositType.find(params[:id])

    if @deposit_type.update_attributes!(params[:deposit_type].permit(:display_name, :deposit_agreement, :deposit_view))
      redirect_to deposit_type_path(@deposit_type), :notice => 'Record was successfully updated.'
    else
      render 'edit'
    end
  end

  private
  def deposit_type_params
    params.require(:deposit_type).permit(:display_name, :deposit_agreement, :deposit_view)
  end

end
