Warble::Application.routes.draw do

  # Main interface
  root to: 'jukeboxes#app'

  # Authentication
  get    'login'                   => 'sessions#new',     as: :login
  delete 'logout'                  => 'sessions#destroy', as: :logout
  match  'auth/:provider/callback' => 'sessions#create'
  match  'auth/failure'            => 'sessions#failure'
  # TODO: more resource friendly?


  ### ------------------------------ API ROUTES --------------------------------

  resources :songs, only: :index
  resource :jukebox, :only => :show do    # TODO: change to resources for multiple jukeboxes
    get  'player', :on => :member
    post 'skip',   :on => :member
    put  'volume', :on => :member

    resource :current_play, controller: :plays, only: :show do
      resources :skips, only: :create
    end
    resources :plays, path: 'playlist', only: [:index, :create] do
      resources :skips, only: :create
    end
  end

  resources :songs, :only => [] do
    resources :votes, :only => :create
  end

  namespace :pandora do
    # TODO: A regular format constraint just returns a 406. We need it to fall
    # through to the catch-all, thus this hack.
    constraints ->(request) { request.format && request.format.json? } do
      resource  :credentials, only: [ :update, :destroy ]
      resources :stations, only: :index do
        resources :songs, only: :index
      end
    end
  end

  match 'hype' => 'hype#index'


  ### ------------------------ ADMINISTRATIVE ROUTES ---------------------------

  # TODO


  ### --------------------------- CATCH-ALL ROUTES -----------------------------

  # These routes catch *everything* that didn't match above. Assumes they are
  # in-app routes and are redirected to the bootstrap.
  #
  # TODO: Add '/' prefix after the hash once this is addressed:
  #   https://github.com/documentcloud/backbone/commit/291863df556d4a84cf5b9056f1d8f55c48441084#commitcomment-590325
  #

  # Build a proc that returns a client-side redirect URI. Escapes the original
  # path to prevent bad URIs -- ActionDispatch's simple string based redirect
  # fails for complex params.
  def catch_all_redirect(prefix = '/')
    ->(params, _) { "#{prefix}##{URI.escape(params[:client_route])}" }
  end

  # Proc-based format constraint for ensuring a 'text/html' Accept header,
  # i.e. a user requested the resource while navigating.
  html_format = ->(request) { request.format && request.format.html? }

  # Check that the request won't be handled by other middleware. Rails routing
  # will catch requests before some middleware has a chance. With catch-all
  # routes, they'd never run. Add any such special routes here.
  not_handled_by_middleware = ->(request) {
    not request.fullpath =~ /^\/users\/auth/
  }

  # Ensures the request is from an authenticated user.
  authenticated_user = ->(request) { request.session[:user_id].present? }

  match '/*client_route' => redirect(catch_all_redirect, status: 302),
        constraints: ->(request) {
          html_format[request] &&
          not_handled_by_middleware[request] &&
          authenticated_user[request]
        }

  match '/*client_route' => redirect(catch_all_redirect('/login'), status: 302),
        constraints: ->(request) {
          html_format[request] &&
          not_handled_by_middleware[request]
          # ... && Unauthenticated
        }
end
