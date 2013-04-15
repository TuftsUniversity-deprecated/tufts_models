class Ability
  include Hydra::Ability

  def custom_permissions
    if current_user.admin?
      can [:show, :add_user, :remove_user, :index], Role
      can [:create, :edit, :update], :all
    end
  end

  def create_permissions
    # nop - override default behavior which allows any registered user to create
  end
end

