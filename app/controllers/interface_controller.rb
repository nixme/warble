class InterfaceController < ApplicationController
  before_filter :authenticate_user!

  def application
  end

  def player
  end
end
