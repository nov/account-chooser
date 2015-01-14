class AccountChooserController < ApplicationController
  after_filter :logging_response

  def status
    authorization_uri = connect_discovery
    if authorization_uri
      render json: {authUri: authorization_uri}
    else
      registered = Account.where(email: params[:email]).exists?
      render json: {registered: registered}
    end
  end

  private

  def connect_discovery
    issuer = OpenIDConnect::Discovery::Provider.discover!(params[:email]).issuer
    provider = OpenIdProvider.where(issuer: issuer).first_or_create!
    redirect_uri = open_id_url(provider)
    provider.associate! redirect_uri unless provider.associated?
    nonce = session[:nonce] = SecureRandom.hex(16)
    provider.client.authorization_uri(
      response_type: :code,
      nonce: nonce,
      scope: [:openid, :profile, :email]
    )
  rescue => e
    logger.info e
    nil
  end

  def logging_response
    logger.info response.body
  end
end
