Web::Application.routes.draw do
  resource :account, except: [:edit, :update]
  resource :account_chooser, only: [] do
    post :status
  end
  resource :google_identity_toolkit, only: [] do
    post  :authenticate
    post  :status
    match :connect
  end
  resource :open_id, only: :show
  resource :session

  root to: 'top#index'
end
