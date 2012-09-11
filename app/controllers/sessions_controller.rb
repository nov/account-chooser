class SessionsController < ApplicationController
  before_filter :require_authentication,   only:   :destroy
  before_filter :require_anonymous_access, except: :destroy

  def new
  end

  def create
    account = Account.where(email: params[:email]).first
    authenticate! account.try(:authenticate, params[:password])
    redirect_to :account
  end

  def destroy
    unauthenticate!
    redirect_to :root
  end
end
