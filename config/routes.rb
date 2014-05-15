ALLOW_DOTS ||= /[a-zA-Z0-9_.:]+/

Tufts::Application.routes.draw do

  resources :batches, only: [:index, :create, :show, :edit, :update] do
    get :new_template_import, on: :collection
    get :new_xml_import, on: :collection
  end

  resources :templates, only: [:index]

  unauthenticated do
    root :to => 'contribute#redirect'
  end

  root :to => "catalog#index", as: :authenticated_root

  Blacklight::Routes.new(self, {}).catalog
  resources :catalog, :only => [:show, :update], :constraints => { :id => ALLOW_DOTS, :format => false }
  get 'advanced/facet' => 'advanced#facet', :as => 'facet_advanced_search'

  resources :unpublished, :only => [:index] do
    member do
      get 'facet'
    end
  end
  # This is from Blacklight::Routes#solr_document, but with the constraints added which allows periods in the id
  resources :solr_document,  :path => 'catalog', :controller => 'catalog', :only => [:show, :update] 
  resources :downloads, :only =>[:show], :constraints => { :id => ALLOW_DOTS }
  resources :deposit_types do
    get 'export', on: :collection
  end

  resources :contribute, as: 'contributions', :controller => :contribute, :only => [:index, :new, :create] do
    collection do
      get 'license'
    end
  end

  mount Qa::Engine => '/qa'
  mount HydraEditor::Engine => '/'

  post 'records/:id/publish', to: 'records#publish', as: 'publish_record', constraints: { id: ALLOW_DOTS }
  put 'records/:id/review', to: 'records#review', as: 'review_record', constraints: { id: ALLOW_DOTS }

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
