class Pandora::BaseController < ApplicationController
  before_filter :check_pandora_credentials!


 private

  def check_pandora_credentials!
    if !$pandora_partner   # Keys not provided via envvars
      head :service_unavailable
    elsif !current_user.pandora_credentials?
      head :forbidden
    end
  end

  def pandora_client
    session[:pandora_user] ||=
      $pandora_partner.login_user(
        current_user.pandora_username,
        current_user.pandora_password
      )
  end
end
