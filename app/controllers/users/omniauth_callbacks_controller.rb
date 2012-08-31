class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def login
    auth = request.env['omniauth.auth']

    # TODO: find or create by
    @identity = Identity.find_with_omniauth(auth) || Identity.create_with_omniauth(auth)

    # Account Linking
    if signed_in?
      # Account is already linked.
      if @identity.user == current_user
        redirect_to root_url
      else
        @identity.user = current_user
        @identity.save
        redirect_to root_url, notice: 'Sweet dood, you linked your account!'
      end
    else
      if @identity.user.present?
        sign_in @identity.user
        redirect_to root_url
      else
        @identity.user = User.find_or_create_by_email_with_omniauth(auth['info'])
        @identity.save
        sign_in @identity.user
        redirect_to root_url
      end
    end
  end

  alias :facebook :login
  alias :do :login

end
