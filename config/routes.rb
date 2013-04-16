Tufts::Application.routes.draw do
  root :to => "catalog#index"

  Blacklight::Routes.new(self, {}).catalog
  # This is from Blacklight::Routes#solr_document, but with the constraints added which allows periods in the id
  resources :solr_document,  :path => 'catalog', :controller => 'catalog', :only => [:show, :update] 
  resources :catalog, :only => [:show, :update], :constraints => { :id => /[a-zA-Z0-9.:]+/ }
  
  HydraHead.add_routes(self)
  mount FcrepoAdmin::Engine => '/admin', :as=> 'fcrepo_admin'
  mount HydraEditor::Engine => '/'
  

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'
end
