class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  password = ENV["SITE_PASSWORD"]
  unless password.blank?
    http_basic_authenticate_with :name => password, :password => password
  end

end
