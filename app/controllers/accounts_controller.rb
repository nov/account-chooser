class AccountsController < ApplicationController
  before_filter :require_authentication,   only: [:show, :destroy]
  before_filter :require_anonymous_access, only: [:new, :create]

  def show
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new params[:account]
    if @account.save
      authenticate! @account
      redirect_to :account
    else
      render :new
    end
  end

  def destroy
    current_account.destroy
    redirect_to :root
  end
end
