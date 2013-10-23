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
    session[:self_deposit_params] ||= {}
    session[:self_deposit_params].deep_merge!(params[:tufts_self_deposit]) if params[:tufts_self_deposit]
    session[:self_deposit_params].merge!({'creator'=>current_user.user_key})      #MHB - this is ugly, how do I make it cleaner?
    session[:self_deposit_params].merge!({'accrualPolicy'=>"Submitted via contributor self-deposit"})
    session[:self_deposit_params].merge!({'provenance'=>"This item was contributed to the repository and authorized by #{current_user} on #{Time.now.strftime('%Y-%m-%d at %H:%M:%S %Z')}"})
    @self_deposit = TuftsSelfDeposit.new(session[:self_deposit_params])
    @self_deposit.current_step = session[:self_deposit_step]

    if params[:back_button]
      @self_deposit.previous_step
    elsif @self_deposit.last_step?
      upload_attachment
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

    #if @self_deposit.valid?
    #  session[:self_deposit_step] = session[:self_deposit_params] = nil
    #  flash[:notice] = "Self deposit saved!"
    #  redirect_to action: 'show', id: @self_deposit
    #else
    #  render "new"
    #end

  end

  def upload_attachment
    dsid = 'Archival.pdf'
    file = params[:tufts_self_deposit][:deposit_attachment]

    warnings = []
    messages = []

    if @self_deposit.valid_type_for_datastream?(dsid, file.content_type)
      messages << "#{dsid} has been added"
    else
      warnings << "You provided a #{file.content_type} file, which is not a valid type for #{dsid}"
    end

    # Persist the object to Fedora, so that we have a valid object and pid before storing the uploaded file
    @self_deposit.save!
    @self_deposit.store_archival_file(dsid, file)

    #respond_to do |format|
    #  @self_deposit.working_user = current_user
    #  if @self_deposit.save(validate: false)
    #    format.html { redirect_to catalog_path(@self_deposit), notice: 'Object was successfully updated.' }
    #    format.json do
    #      if warnings.empty?
    #        render json: {message: messages.join(". "), status: 'success'}
    #      else
    #        render json: {message: warnings.join(". "), status: 'error'}
    #      end
    #    end
    #  else
    #    format.html { render action: "edit" }
    #    format.json { render json: @self_deposit.errors, status: :unprocessable_entity }
    #  end
    #end
  end

end