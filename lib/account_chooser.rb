module AccountChooser
  module Script
    module_function

    def load(options = {})
      config = options.inject('') do |config, (key, value)|
        config << "window.accountchooser.CONFIG.#{key} = #{value.to_json};\n"
      end
      script = <<-SCRIPT
      <script type="text/javascript" src="https://www.accountchooser.com/ac.js"></script>
      <script>
        #{config}
        window.accountchooser.USER_STATUS_TIMEOUT_ = 5000;
      </script>
      SCRIPT
      script.html_safe
    end
  end
end