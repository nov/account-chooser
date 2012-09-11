module ApplicationHelper
  include Authentication::HelperMethods

  def account_chooser_script(options = {})
    script = <<-SCRIPT
    <script type='text/javascript' src='https://www.accountchooser.com/ac.js'>
      #{options.to_json[1..-2]}
    </script>
    SCRIPT
    script.html_safe
  end
end
