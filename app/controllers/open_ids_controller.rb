class OpenIdsController < ApplicationController
  def show
    provider = OpenIdProvider.find params[:id]
    authenticate! *provider.authenticate(
      open_id_url(provider),
      params[:code],
      session[:nonce]
    )
    redirect_to :account
  end
end
