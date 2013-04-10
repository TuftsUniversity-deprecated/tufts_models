class Ability
  include Hydra::Ability

  def custom_permissions
    if current_user.admin?
      can [:index, :edit, :destroy], [User, Role]
      can :create, :all
    end
  end

  def create_permissions
    # nop - override default behavior which allows any registered user to create
  end
end

