Tufts::Application.routes.draw do
  root :to => "catalog#index"

  Blacklight::Routes.new(self, {}).catalog
  # This is from Blacklight::Routes#solr_document, but with the constraints added which allows periods in the id
  resources :solr_document,  :path => 'catalog', :controller => 'catalog', :only => [:show, :update] 
  resources :catalog, :only => [:show, :update], :constraints => { :id => /[a-zA-Z0-9.:]+/ }
  resources :download, :only =>[:show]
  
  HydraHead.add_routes(self)
  mount FcrepoAdmin::Engine => '/admin', :as=> 'fcrepo_admin'
  mount HydraEditor::Engine => '/'
  match 'records/:id/publish' => 'records#publish', via: :post, as: 'publish_record', constraints: { id: /[a-zA-Z0-9.:]+/ }
  

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'
end
