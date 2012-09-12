module GoogleIdentityToolkit
  module_function

  class InvalidAssertion < StandardError; end

  def developer_key
    'AIzaSyCP35KLQejpzJtpyYwiJhyR-KGGPG99fu4'
  end

  def verify(request)
    params = {
      requestUri: request.url,
      postBody: request.post? ? request.body.read : request.query_string
    }
    Rails.logger.info params
    endpoint = "https://www.googleapis.com/identitytoolkit/v1/relyingparty/verifyAssertion?key=#{developer_key}"
    response = RestClient.post endpoint, params.to_json, :content_type => :json
    assertion = JSON.parse response, symbolize_names: true
    raise InvalidAssertion.new('no verified email') unless assertion.include? :verifiedEmail
    assertion
  rescue RestClient::RequestFailed, JSON::ParseError => e
    raise InvalidAssertion.new(e.message)
  end

  module Script
    module_function

    def load(target_dom_id, account, options = {})
      options.merge!(
        developerKey: GoogleIdentityToolkit.developer_key,
        idps: ["Gmail", "AOL", "Hotmail", "Yahoo"],
        tryFederatedFirst: true,
        useCachedUserStatus: false
      )
      script = <<-SCRIPT
      <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.2/jquery-ui.min.js"></script>
      <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/googleapis/0.0.4/googleapis.min.js"></script>
      <script type="text/javascript" src="https://ajax.googleapis.com/jsapi"></script>
      <script type="text/javascript">
        google.load("identitytoolkit", "1.0", {packages: ["ac", "notify"]});
        $(function (){
          window.google.identitytoolkit.setConfig(#{options.to_json});
          $('##{target_dom_id}').accountChooser();
        });
      </script>
      SCRIPT
      if account
        userData = {
          email: account.email,
          displayName: account.name,
          photoUrl: account.photo
        }
        script << <<-SCRIPT
        <script type="text/javascript">
          $(function (){
            window.google.identitytoolkit.updateSavedAccount(#{userData.to_json});
            window.google.identitytoolkit.showSavedAccount(#{userData[:email].to_json});
          });
        </script>
        SCRIPT
      end
      script.html_safe
    end

    def notify(account)
      script = <<-SCRIPT
      <script type='text/javascript' src='https://ajax.googleapis.com/jsapi'></script>
      <script type='text/javascript'> 
        google.load("identitytoolkit", "1.0", {packages: ["notify"]});
      </script> 
      <script type='text/javascript'>
        <% if authenticated? %>
          window.google.identitytoolkit.notifyFederatedSuccess();
        <% else %>
          window.google.identitytoolkit.notifyFederatedError();
        <% end %>
      </script>
      SCRIPT
      script << if account
        options = {
          email: account.email,
          registered: true
        }
        <<-SCRIPT
        <script type='text/javascript'>
          window.google.identitytoolkit.notifyFederatedSuccess(#{options.to_json});
        </script>
        SCRIPT
      else
        <<-SCRIPT
        <script type='text/javascript'>
          window.google.identitytoolkit.notifyFederatedError();
        </script>
        SCRIPT
      end
      script.html_safe
    end
  end
end