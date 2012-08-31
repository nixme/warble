class ApplicationController < ActionController::Base
  protect_from_forgery    # CSRF protection filter

  before_filter :authenticate_user!

end
