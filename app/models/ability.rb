class Ability
  include Hydra::Ability

  def custom_permissions
    if current_user.registered?
      can [:create], Contribution
    end

    if current_user.admin?
      can_read_all_documents
      can [:create, :show, :add_user, :remove_user, :index], Role
      can [:create, :read, :update, :review, :publish, :destroy], ActiveFedora::Base
      can [:create, :read, :update, :destroy, :export], DepositType
      can [:index, :new_template_import, :new_xml_import, :create, :show], Batch
    end
  end

  # Read any document deposited by any user
  def can_read_all_documents
    can :read, SolrDocument
  end

  def create_permissions
    # nop - override default behavior which allows any registered user to create
  end
end

