Web::Application.routes.draw do
  resource :account do
    post :status
    match :connect
  end
  resource :session

  root to: 'top#index'
end
