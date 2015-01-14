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
    id_token_string = request.cookies[:gtoken]
    id_token = JSON::JWT.decode id_token_string, :skip_verification # TODO: actually, need to verify id_token signature.

  end

  module Script
    module_function

    def load_script
      <<-SCRIPT
        <script type="text/javascript" src="//www.gstatic.com/authtoolkit/js/gitkit.js"></script>
        <link type=text/css rel=stylesheet href="//www.gstatic.com/authtoolkit/css/gitkit.css" />
      SCRIPT
    end

    def widget(selector, options = {})
      options.merge!(
        apiKey: GoogleIdentityToolkit.developer_key
      )
      script = <<-SCRIPT
        #{load_script}
        <script type="text/javascript">
          $(function () {
            window.google.identitytoolkit.signInButton(
              '#{selector}',
              #{options.to_json}
            );
            window.google.identitytoolkit.start(
              '#{selector}',
              #{options.to_json}
            );
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