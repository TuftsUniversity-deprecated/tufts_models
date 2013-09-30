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

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  # As currently spec'ed, every registered user is a 'contributor'
  after_create :add_contributor_role

  def to_s
    email
  end

  # Returns true iff the user roles contains 'contributor'
  def contributor?
    roles.where(name: 'contributor').exists?
  end

  private
    # Adds the 'contributor' role to this user
    def add_contributor_role
      roles << Role.where(name: 'contributor').first_or_create
    end
end
