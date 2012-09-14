class AccountChooserController < ApplicationController
  def status
    authorization_uri = discover_connect_op
    if authorization_uri
      render json: {authUri: authorization_uri}
    else
      registered = Account.where(email: params[:email]).exists?
      render json: {registered: registered}
    end
  end

  private

  def discover_connect_op
    provider = OpenIDConnect::Discovery::Provider.discover! params[:email]
    config = OpenIDConnect::Discovery::Provider::Config.discover! provider.location
    client_credentials = OpenIDConnect::Client::Registrar.new(
      config.registration_endpoint,
      application_name: Web::Application.config.name,
      application_type: 'web',
      redirect_uris: open_id_url,
      user_id_type: 'pairwise'
    ).associate!
    OpenIDConnect::Client.new(
      config.as_json.merge(identifier: client_credentials.identifier)
    ).authorization_uri(
      response_type: :code,
      nonce: SecureRandom.hex(16),
      scope: [:openid, :profile, :email]
    )
  rescue OpenIDConnect::Discovery::DiscoveryFailed => e
    nil
  end
end
