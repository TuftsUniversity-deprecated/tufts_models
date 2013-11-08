class DepositTypesController < ApplicationController
  before_action :load_deposit_type, only: :create
  load_and_authorize_resource

  def index
  end

  def export
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
  end

  def destroy
    @deposit_type.destroy
    redirect_to deposit_types_path
  end

  def create
    if @deposit_type.save
      redirect_to deposit_type_path(@deposit_type)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @deposit_type.update(deposit_type_params)
      redirect_to deposit_type_path(@deposit_type), :notice => 'Record was successfully updated.'
    else
      render 'edit'
    end
  end

private

  def load_deposit_type
    @deposit_type = DepositType.new(deposit_type_params)
  end

  def deposit_type_params
    params.require(:deposit_type).permit(:display_name, :deposit_agreement, :deposit_view, :license_name, :source)
  end

end
