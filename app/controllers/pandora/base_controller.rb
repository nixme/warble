class Pandora::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_pandora_credentials!

 protected
  def check_pandora_credentials!
    unless current_user.pandora_credentials?
      head :forbidden
    end
  end
end
