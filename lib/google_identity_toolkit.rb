module GoogleIdentityToolkit
  module_function

  class InvalidAssertion < StandardError; end

  def version
    2
  end

  def developer_key
    'AIzaSyCP35KLQejpzJtpyYwiJhyR-KGGPG99fu4'
  end

  def verify(request)
    params = {
      requestUri: request.url,
      postBody:   request.post? ? request.body.read : request.query_string
    }
    endpoint = "https://www.googleapis.com/identitytoolkit/v#{version}/relyingparty/verifyAssertion?key=#{developer_key}"
    response = RestClient.post endpoint, params.to_json, :content_type => :json
    assertion = JSON.parse response, symbolize_names: true
    raise InvalidAssertion.new('no verified email') unless assertion.include? :emailVerified
    assertion
  rescue RestClient::RequestFailed, JSON::ParserError => e
    raise InvalidAssertion.new(e.message)
  end

  module Script
    module_function

    def load_script(*packages)
      <<-SCRIPT
        <script type='text/javascript' src='https://ajax.googleapis.com/jsapi'></script>
        <script type="text/javascript" src="https://www.accountchooser.com/client.js"></script>
        <script type="text/javascript">
          google.load("identitytoolkit", "#{GoogleIdentityToolkit.version}", {packages: #{packages.to_json}});
        </script>
      SCRIPT
    end

    def init(options = {})
      options.merge!(
        developerKey: GoogleIdentityToolkit.developer_key,
        idps: ["Gmail", "AOL", "Hotmail", "Yahoo"],
        tryFederatedFirst: true,
        useContextParam: true
      )
      script = <<-SCRIPT
        <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.2/jquery-ui.min.js"></script>
        <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/googleapis/0.0.4/googleapis.min.js"></script>
        #{load_script 'ac'}
        <script type="text/javascript">
          $(function (){
            window.google.identitytoolkit.setConfig(#{options.to_json});
            window.google.identitytoolkit.init();
          });
        </script>
      SCRIPT
      script.html_safe
    end

    def store(account, options = {})
      user_data = {
        email:       account.email,
        displayName: account.name,
        photoUrl:    account.photo
      }
      script = <<-SCRIPT
        #{load_script 'store'}
        <script type="text/javascript">
          $(function (){
            window.google.identitytoolkit.storeAccount(#{user_data.to_json}, #{options[:homeUrl].to_json});
          });
        </script>
      SCRIPT
      script.html_safe
    end
  end
end