# based heavily on http://bazaar.launchpad.net/~kevin-mehall/pithos/trunk/view/head:/pithos/pandora/pandora.py, basically a port

require 'pandora/blowfish'
require 'xmlrpc/client'

module Pandora
  class Client < XMLRPC::Client
    PROTOCOL_VERSION = 33
    HOST = 'www.pandora.com'
    RPC_PATH = "/radio/xmlrpc/v#{PROTOCOL_VERSION}?%s"
    USER_AGENT = "Warble/0.0.1"

    attr_accessor :stations

    def initialize(username, password)
      super(HOST, RPC_PATH, nil, nil, nil, nil, nil, true)
      @encryptor = Blowfish.encryptor
      @decryptor = Blowfish.decryptor
      login(username, password)
    end

    def decrypt(str)
      @decryptor.decrypt(str)
    end

    # override calling mechanism to add extra request parameters
    def call2(method, *args)
      if args
        server_time = Time.now.to_i - (@time_offset || 0)
        args.insert(0, server_time) unless method == 'misc.sync'
        args.insert(1, @authToken) if @authToken
      end

      url_args = [ "rid=#{@rid}", "method=#{method.split('.').last}" ]
      url_args << "lid=#{@listenerId}" if @listenerId
      @path = RPC_PATH % url_args.join('&')

      super(method, *args)
    end

    # override normal rpc mechanism to encrypt bodies
    def do_rpc(request, async = false)
      request = @encryptor.encrypt(request.gsub(/\n/, ''))
      response = super(request, async)
      @http.finish if @http  # ensure we don't keep connections hanging
      response
    end

    def login(user, pass)
      # Determine offset between our time and Pandora server time
      @rid = "%07iP" % (Time.now.to_i % 10000000)
      if response = call('misc.sync')
        server_time = @decryptor.decrypt(response)[4..-3].to_i
        @time_offset = Time.now.to_i - server_time
      end

      # Authenticate
      response = call 'listener.authenticateListener', user, pass, 'html5tuner',
        '', '', 'HTML5', true

      @authToken  = response['authToken']
      @listenerId = response['listenerId']

      @stations = call('station.getStations').map do |station_data|
        Station.new(self, station_data)
      end
    end

    # type is either :shared or :music_id
    def create_station(type, id)
      tag = (type == :shared ? 'sh' : 'mi')
      @stations ||= []
      @stations << Station.new(self, call('station.createStation', tag + id))
    end

    def search
      # TODO...
    end

    class Station
      AUDIO_FORMAT = 'aacplus'

      attr_accessor :name, :id, :token, :data

      def initialize(client, data)
        @client = client
        @data   = data
        @id     = data['stationId']
        @token  = data['stationIdToken']
        @name   = data['stationName']
      end

      def next_playlist
        @client.call('playlist.getFragment', @id, '0', '', '',
          AUDIO_FORMAT, '0', '0').map do |song_data|
          Song.new(@client, song_data)
        end
      end

      def info_url
        "http://www.pandora.com/stations/#{token}"
      end

      def rename(new_name)
        return if new_name == @name
        @client.call 'station.setStationName', @id, new_name
        @name = new_name
      end

      def delete
        @client.call 'station.removeStation', @id
      end
    end

    class Song
      attr_accessor :title, :artist, :album, :audio_url,
      :music_id, :station_id, :artist_id,
      :art_url, :artist_art_url,
      :rating, :tired, :data

      def initialize(client, data)
        @client         = client
        @data           = data
        @title          = data['songTitle']
        @artist         = data['artistSummary']
        @album          = data['albumTitle']
        @music_id       = data['musicId']
        @station_id     = data['stationId']
        @artist_id      = data['artistMusicId']
        @art_url        = data['artRadio']
        @artist_art_url = data['artistArtUrl']
        @rating         = (data['rating'] == 1 ? :love : :normal)
        @tired          = false

        # decrypt music stream url
        url = data['audioURL']
        @audio_url = url[0...-48] + @client.decrypt(url[-48..-1])
      end

      def love
        if @rating != :love
          @client.call ''
          @rating = :love
        end
      end

      def ban
        if @rating != :ban
          @client.call ''
          @rating = :ban
        end
      end

      def tired
      end

      def bookmark
        @client.call 'station.createBookmark', @station_id, @music_id
      end

      def bookmark_artist
        @client.call 'station.createArtistBookmark', @artist_id
      end
    end
  end
end
