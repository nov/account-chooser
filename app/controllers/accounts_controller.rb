class AccountsController < ApplicationController
  before_filter :require_authentication,   only:   [:show, :destroy]
  before_filter :require_anonymous_access, except: [:show, :destroy, :status, :connect]

  def status
    provider = OpenIDConnect::Discovery::Provider.discover! params[:email]
    json = if provider
      {authUri: provider.location}
    else
      registered = Account.where(email: params[:email]).exists?
      {registered: registered}
    end
    logger.info json
    render json: json
  end

  def connect
    assertion = GoogleIdentityToolkit.verify request
    account = Account.authenticate(assertion)
    authenticate! account if account
  end

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
