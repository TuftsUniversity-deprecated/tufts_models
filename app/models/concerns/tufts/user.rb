module Tufts::User
  extend ActiveSupport::Concern

  # Connects this user object to Role behaviors.
  include Hydra::RoleManagement::UserRoles
  include WithPersonalCollections

  def registered?
    groups.include?('registered')
  end

  def display_name  #update this method to return the string you would like used for the user name stored in fedora objects.
    user_key
  end
end
