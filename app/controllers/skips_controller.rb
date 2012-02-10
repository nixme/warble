class SkipsController < ApplicationController
  def create
    Jukebox.skip
    head :ok
  end
end
