class ApplicationController < ActionController::Base
  protect_from_forgery    # CSRF protection filter

  def authenticate_user!
    unless current_user
      redirect_to login_url
      false
    end
  end

  def current_user
    @current_user ||= User[session[:user_id]]
  end
end
