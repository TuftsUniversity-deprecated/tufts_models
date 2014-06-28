module Tufts::User
  extend ActiveSupport::Concern

  include do
    # Connects this user object to Role behaviors. 
    include Hydra::RoleManagement::UserRoles
  end

  def registered?
    self.groups.include?('registered')
  end

  def display_name  #update this method to return the string you would like used for the user name stored in fedora objects.
    self.user_key
  end

end
