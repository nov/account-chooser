class ApplicationController < ActionController::Base
  include Authentication

  protect_from_forgery

  rescue_from Authentication::Unauthorized do |e|
    redirect_to :new_session, flash: {error: e.message}
  end
end
