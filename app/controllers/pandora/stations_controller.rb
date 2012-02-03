class Pandora::StationsController < Pandora::BaseController
  respond_to :json

  def index
    stations = current_user.pandora_client(session).stations.map do |station|
      {
        name:  station.name,
        id:    station.id,
        token: station.token
      }
    end
    respond_with stations
  end
end
