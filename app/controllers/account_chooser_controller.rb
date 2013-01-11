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
    issuer = OpenIDConnect::Discovery::Provider.discover!(params[:email]).location
    provider = OpenIdProvider.where(issuer: issuer).first_or_create!
    provider.associate! open_id_url(provider) unless provider.associated?
    nonce = session[:nonce] = SecureRandom.hex(16)
    provider.client.authorization_uri(
      response_type: :code,
      nonce: nonce,
      scope: [:openid, :profile, :email]
    )
  rescue OpenIDConnect::Discovery::DiscoveryFailed => e
    nil
  end

  def logging_response
    logger.info response.body
  end
end
