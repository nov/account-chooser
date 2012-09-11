Web::Application.routes.draw do
  resource :account do
    post :status
  end
  resource :session

  root to: 'top#index'
end
