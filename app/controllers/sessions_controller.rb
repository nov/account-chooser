class SessionsController < ApplicationController
  before_filter :require_authentication,   only: :destroy
  before_filter :require_anonymous_access, only: :new

  def new
  end

  def create
    account = Account.where(email: params[:email]).first
    authenticate! account.try(:authenticate, params[:password])
    if request.xhr?
      render json: {status: 'OK'}
    else
      redirect_to :account
    end
  end

  def destroy
    unauthenticate!
    redirect_to :root
  end
end
