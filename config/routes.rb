Tufts::Application.routes.draw do
  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)
  mount FcrepoAdmin::Engine => '/admin', :as=> 'fcrepo_admin'
  mount HydraEditor::Engine => '/'
  

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'
end
