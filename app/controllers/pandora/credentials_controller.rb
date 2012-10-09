module Pandora
  class CredentialsController < BaseController
    skip_before_filter :check_pandora_credentials!, :only => :update
    respond_to :json

    def update
      @user = current_user
      @user.pandora_username = params[:pandora_username]
      @user.pandora_password = params[:pandora_password]
      @user.save
      head :no_content
    end

    def destroy
      current_user.clear_pandora_credentials!
      head :no_content
    end
  end
end
