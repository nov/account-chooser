module GoogleIdentityToolkit
  module_function

  class InvalidAssertion < StandardError; end

  def version
    3
  end

  def developer_key
    'AIzaSyAhM-n9L6LNS9oDVZ_4trTlZ8UjtQi029c'
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

    def load_script
      <<-SCRIPT
        <script type="text/javascript" src="//www.gstatic.com/authtoolkit/js/gitkit.js"></script>
        <link type=text/css rel=stylesheet href="//www.gstatic.com/authtoolkit/css/gitkit.css" />
      SCRIPT
    end

    def login(selector, options = {})
      options.merge!(
        apiKey: GoogleIdentityToolkit.developer_key
      )
      script = <<-SCRIPT
        #{load_script}
        <script type="text/javascript">
          /*
          window.google.identitytoolkit.signInButton(
            '#{selector}',
            #{options.to_json}
          );
          */
          window.google.identitytoolkit.start(
            '#{selector}',
            #{options.to_json}
          );
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
        #{load_script}
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