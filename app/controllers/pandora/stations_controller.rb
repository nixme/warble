module Pandora
  class StationsController < BaseController
    respond_to :json

    def index
      retry_on_auth_failure do |pandora_client|
        stations = pandora_client.stations.map do |station|
          {
            name:  station.name,
            id:    station.id,
            token: station.token
          }
        end
        respond_with stations
      end
    end
  end
end
