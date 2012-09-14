class OpenIdProvider < ActiveRecord::Base
  attr_accessible :identifier, :secret, :expires_at, :issuer, :authorization_endpoint, :token_endpoint, :user_info_endpoint, :x509_url

  has_many :open_ids

  def expired?
    expires_at.try(:past?)
  end

  def associated?
    identifier.present? && !expired?
  end

  def associate!(redirect_uri)
    config = OpenIDConnect::Discovery::Provider::Config.discover! issuer
    client = OpenIDConnect::Client::Registrar.new(
      config.registration_endpoint,
      application_name: Web::Application.config.name,
      application_type: :web,
      redirect_uris:    redirect_uri,
      user_id_type:     :pairwise
    ).associate!
    update_attributes!(
      identifier:             client.identifier,
      secret:                 client.secret,
      expires_at:             client.expires_in.try(:from_now),
      authorization_endpoint: config.authorization_endpoint,
      token_endpoint:         config.token_endpoint,
      x509_url:               config.x509_url
    )
  end

  def client
    @client ||= OpenIDConnect::Client.new(
      identifier:             identifier,
      secret:                 secret,
      authorization_endpoint: authorization_endpoint,
      token_endpoint:         token_endpoint
    )
  end

  def public_key
    @cert ||= OpenSSL::X509::Certificate.new open(x509_url).read
    @cert.public_key
  end

  def authenticate(redirect_uri, code, nonce)
    client.redirect_uri = redirect_uri
    client.authorization_code = code
    access_token = client.access_token!
    _id_token_ = OpenIDConnect::ResponseObject::IdToken.decode access_token.id_token, public_key
    _id_token_.verify!(
      issuer:    issuer,
      client_id: identifier,
      nonce:     nonce
    )
    open_id = self.open_ids.find_or_initialize_by_identifier _id_token_.user_id
    open_id.save!
    provider_domain = URI.parse(issuer).host
    if open_id.account
      open_id.account
    else
      account = Account.new(
        open_id: open_id,
        name: provider_domain,
        email: 'me@provider_domain'
      )
      account.skip_password_validation = true
      account.save!
      account
    end
  end
end
