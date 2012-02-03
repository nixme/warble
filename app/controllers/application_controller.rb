class ApplicationController < ActionController::Base
  protect_from_forgery    # CSRF protection filter

  def authenticate_user!
    unless current_user
      redirect_to login_url
    end
  end

  def current_user
    @current_user =
      begin
        if session[:user_id] && (user = User.find_by_id(session[:user_id]))
          user
        else
          reset_session
          nil
        end
      end
  end
end
