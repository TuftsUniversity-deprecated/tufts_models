class Ability
  include Hydra::Ability

  def custom_permissions
    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index], Role
      can [:create, :edit, :update, :publish, :destroy], ActiveFedora::Base
    elsif current_user.contributor?
      # TODO: define correct permissions for contributor role
      can [:create, :edit, :update], TuftsSelfDeposit
    end
  end

  def create_permissions
    # nop - override default behavior which allows any registered user to create
  end
end

