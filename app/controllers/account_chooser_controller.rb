class AccountChooserController < ApplicationController
  def status
    provider = OpenIDConnect::Discovery::Provider.discover! params[:email]
    config = OpenIDConnect::Discovery::Provider::Config.discover! provider.location
    client = OpenIDConnect::Client::Registrar.new(
      config.registration_endpoint,
      application_name: Web::Application.config.name,
      application_type: 'web',
      redirect_uris: redirect_uri,
      user_id_type: 'pairwise'
    ).associate!
    render json: {authUri: provider.location}
  rescue OpenIDConnect::Discovery::DiscoveryFailed => e
    registered = Account.where(email: params[:email]).exists?
    render json: {registered: registered}
  end
end
