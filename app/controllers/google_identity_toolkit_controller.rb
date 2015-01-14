class GoogleIdentityToolkitController < AccountChooserController
  def show
  end

  def status
    super
  end

  def connect
    id_token = GoogleIdentityToolkit.verify request
    account = Account.authenticate id_token
    authenticate! account if account
  end

  def authenticate
    account = Account.where(email: params[:email]).first
    authenticate! account.try(:authenticate, params[:password])
    render json: {status: 'OK'}
  end
end
