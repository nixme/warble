helpers do
  def authenticated?
    session[:user_id]
  end
end
