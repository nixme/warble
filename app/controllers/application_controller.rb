class ApplicationController < ActionController::Base
  # TODO: re-enable CSRF protection after fixing ajax to push the token
  #protect_from_forgery    # CSRF protection filters

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
