Web::Application.routes.draw do
  resource :account, except: [:edit, :update]
  resource :account_chooser, only: [] do
    match :status
  end
  resource :google_identity_toolkit, only: [:show] do
    post  :authenticate
    match :status
    match :connect
  end
  resources :open_ids, only: :show
  resource :session

  root to: 'top#index'
end
