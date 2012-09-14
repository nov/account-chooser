class GoogleIdentityToolkitController < AccountChooserController
  def status
    super
  end

  def connect
    assertion = GoogleIdentityToolkit.verify request
    account = Account.authenticate(assertion)
    authenticate! account if account
  end

  def authenticate
    account = Account.where(email: params[:email]).first
    authenticate! account.try(:authenticate, params[:password])
    render json: {status: 'OK'}
  end
end
