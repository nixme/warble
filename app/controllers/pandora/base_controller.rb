module Pandora
  class BaseController < ApplicationController
    before_filter :check_pandora_credentials!


   private

    def check_pandora_credentials!
      if !$pandora_partner   # Keys not provided via envvars
        head :service_unavailable
      elsif !current_user.pandora_credentials?
        render json: { error: :missing_credentials }, status: :forbidden
      end
    end

    # Run the given block with the pandora client. Reauthenticate and retry if
    # a Pandora 1001 INVALID_AUTH_TOKEN is raised.
    def retry_on_auth_failure(&block)
      retried = false
      begin
        yield pandora_client
      rescue Pandora::APIError => ex
        if !retried && ex.code == 1001  # INVALID_AUTH_TOKEN
          pandora_client.reauthenticate
          retried = true
          retry
        else
          raise
        end
      end
    end

    # Current user's Pandora session stored in the cookie session.
    def pandora_client
      session[:pandora_user] ||=
        $pandora_partner.login_user(
          current_user.pandora_username,
          current_user.pandora_password
        )
    end
  end
end
