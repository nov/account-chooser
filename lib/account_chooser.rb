module AccountChooser
  module Script
    module_function

    def load(options = {})
      script = <<-SCRIPT
      <script type="text/javascript" src="https://www.accountchooser.com/ac.js">
        #{options.to_json[1..-2]}
      </script>
      <script>
        window.accountchooser.cdshelper.USER_STATUS_TIMEOUT_ = 5000;
      </script>
      SCRIPT
      script.html_safe
    end
  end
end