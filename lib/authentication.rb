module Authentication
  class AuthenticationFailed < StandardError; end

  def self.included(klass)
    klass.send :include, Authentication::HelperMethods
    klass.send :include, Authentication::ControllerMethods
  end

  module HelperMethods
    def current_account
      @current_account ||= Account.find(session[:current_account])
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def current_provider
      @current_provider ||= OpenIdProvider.find session[:current_provider] if session[:current_provider]
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def authenticated?
      !current_account.blank?
    end
  end

  module ControllerMethods
    def self.included(klass)
      klass.send :rescue_from, Authentication::AuthenticationFailed do |e|
        if request.xhr?
          render json: {status: 'passwordError'}
        else
          redirect_to :root, flash: {error: e.message}
        end
      end
    end

    def require_authentication
      authenticate! Account.find_by_id(session[:current_account])
    rescue AuthenticationFailed => e
      redirect_to :root and return false
    end

    def require_anonymous_access
      redirect_to :root if authenticated?
    end

    def authenticate!(account, open_id = nil)
      raise AuthenticationFailed unless account
      session[:current_account] = account.id
      session[:current_provider] = open_id.open_id_provider.id if open_id
    end

    def unauthenticate!
      @current_account = session[:current_account] = nil
      @current_provider = session[:current_provider] = nil
    end
  end
end