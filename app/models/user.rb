class User < ActiveRecord::Base
# Connects this user object to Hydra behaviors. 
 include Hydra::User
# Connects this user object to Role behaviors. 
 include Hydra::RoleManagement::UserRoles
# Connects this user object to Blacklights Bookmarks. 
 include Blacklight::User
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def to_s
    email
  end

  def registered?
    self.groups.include?('registered')
  end

  def display_name  #update this method to return the string you would like used for the user name stored in fedora objects.
    self.user_key
  end

end
