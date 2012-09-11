class SessionsController < ApplicationController
  def new
  end

  def create
    account = Account.where(email: params[:email]).first
    authenticate! account.try(:authenticate, params[:password])
    redirect_to :root
  end

  def destroy
    unauthenticate!
    redirect_to :root
  end
end
