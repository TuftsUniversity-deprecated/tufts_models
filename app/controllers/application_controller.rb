class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  layout 'blacklight'

  protect_from_forgery
  before_filter :authenticate_user!
  #before_filter :must_be_admin

  def must_be_admin
    render(file: "public/401", status: :unauthorized, layout: nil) unless devise_controller? || current_user.admin?
  end

  
  def after_sign_in_path_for(resource)
    root_path
  end

  # Catch permission errors
  rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
    if (exception.action == :edit) and current_user.admin?
      redirect_to(catalog_path(params[:id]), :alert => "You do not have sufficient privileges to edit this document.")
    elsif (exception.action == :edit) and current_user.registered?
      redirect_to(contributions_path, :alert => "You do not have sufficient privileges to edit this document.")
    elsif current_user and current_user.persisted?
      redirect_to root_url, :alert => exception.message
    else
      session["user_return_to"] = request.url
      redirect_to new_user_session_url, :alert => exception.message
    end
  end
end
