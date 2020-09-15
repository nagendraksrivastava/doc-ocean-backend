class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  include Authenticable

  def after_sign_in_path_for(user)
    if user.internal?
      admin_dashboard_path
    else
      visitors_path
    end
  end
end
