Warble::Application.routes.draw do

  # interface
  root :to => 'jukeboxes#show'

  # authentication
  match 'login'                   => 'sessions#new',     :as => :login
  match 'logout'                  => 'sessions#destroy', :as => :logout   # TODO: should be a DELETE (or POST at least)
  match 'auth/:provider/callback' => 'sessions#create'
  match 'auth/failure'            => 'sessions#failure'
  # TODO: more resource friendly?

  # API endpoints
  resource :jukebox, :only => :show do    # TODO: change to resources for multiple jukeboxes
    get  'player', :on => :member
    post 'skip',   :on => :member
    get  'search', :on => :member
    put  'volume', :on => :member
    resources :songs, :only => [ :index, :create ]
  end
  namespace :pandora do
    resource  :credentials, :only => [ :update, :destroy ]
    resources :stations, :only => :index do
      resources :songs, :only => :index
    end
  end

  match 'hype' => 'hype#index'

  # resque admin interface
  mount Resque::Server.new, :at => '/resque'
end
