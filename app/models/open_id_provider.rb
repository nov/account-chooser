class OpenIdProvider < ActiveRecord::Base
  attr_accessible :identifier, :secret, :redirect_uri, :expires_at, :issuer, :authorization_endpoint, :token_endpoint, :userinfo_endpoint, :jwks_uri

  has_many :open_ids

  def expired?
    expires_at.try(:past?)
  end

  def associated?
    identifier.present? && !expired?
  end

  def config
    @config ||= OpenIDConnect::Discovery::Provider::Config.discover! issuer
  end

  def associate!(redirect_uri)
    client = OpenIDConnect::Client::Registrar.new(
      config.registration_endpoint,
      client_name:      Web::Application.config.name,
      application_type: :web,
      redirect_uris:    [redirect_uri]
    ).register!
    update_attributes!(
      identifier:   client.identifier,
      secret:       client.secret,
      redirect_uri: redirect_uri
    )
  end

  def client
    @client ||= OpenIDConnect::Client.new(
      identifier:             identifier,
      secret:                 secret,
      redirect_uri:           redirect_uri,
      authorization_endpoint: config.authorization_endpoint,
      userinfo_endpoint:      config.userinfo_endpoint,
      token_endpoint:         config.token_endpoint
    )
  end

  def public_key
    @public_key ||= config.public_keys.first
  end

  def authenticate(redirect_uri, code, nonce)
    client.authorization_code = code
    access_token = client.access_token!
    _id_token_ = OpenIDConnect::ResponseObject::IdToken.decode access_token.id_token, public_key
    _id_token_.verify!(
      issuer:    issuer,
      client_id: identifier,
      nonce:     nonce
    )
    open_id = self.open_ids.find_or_initialize_by_identifier _id_token_.sub
    open_id.save!
    userinfo = access_token.userinfo!
    provider_domain = URI.parse(issuer).host
    account = if open_id.account
      open_id.account
    else
      account = Account.where(email: userinfo.email).first_or_initialize(
        name: userinfo.name
      )
      account.skip_password_validation!
      account.open_ids << open_id
      logger.info account
      account.save!
      account
    end
    [account, open_id]
  end
end
