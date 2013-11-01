ALLOW_DOTS ||= /[a-zA-Z0-9_.:]+/

Tufts::Application.routes.draw do

  unauthenticated do
    root :to => 'contribute#redirect'
  end

  root :to => "catalog#index"

  resources :catalog, :only => [:show, :update], :constraints => { :id => ALLOW_DOTS, :format => false }
  Blacklight::Routes.new(self, {}).catalog
  resources :unpublished, :only => [:index] do
    member do
      get 'facet'
    end
  end
  # This is from Blacklight::Routes#solr_document, but with the constraints added which allows periods in the id
  resources :solr_document,  :path => 'catalog', :controller => 'catalog', :only => [:show, :update] 
  resources :downloads, :only =>[:show], :constraints => { :id => ALLOW_DOTS }
  resources :self_deposits, :constraints => { :id => ALLOW_DOTS }
  resources :deposit_types, :constraints => { :id => ALLOW_DOTS } do
    get 'export', on: :collection
  end

  resource :contribute, :controller => :contribute, :only => [:home, :license, :new, :create] do
    get '/', :to => 'contribute#home'
    get 'home'
    get 'license'
  end

  HydraHead.add_routes(self)
  
  mount HydraEditor::Engine => '/'
  post 'records/:id/publish', to: 'records#publish', as: 'publish_record', constraints: { id: ALLOW_DOTS }

  resources :records, only: [:destroy], constraints: { id: ALLOW_DOTS } do
    member do
      delete 'cancel'
    end
    resources :attachments, constraints: { id: ALLOW_DOTS }
  end
    
  resources :generics, only: [:edit, :update], constraints: { id: ALLOW_DOTS }

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'
end
