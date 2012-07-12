class SessionsController < ApplicationController
  skip_before_filter :authenticate_user!, except: :destroy
  def destroy
    self.current_user = nil
    redirect_to login_url
  end
  def failure
    # TODO: replace with a proper fail page
    render :text => 'Uh oh... something went wrong authenticating you'
  end
end
