require 'patron'
require 'nokogiri'
require 'execjs'

# TODO:
#  - error handling umm everywhere
#  - getting a proper list takes 1+N page fetches
#  - change to Typhoeus for parallel http requests?
#  - caching?

class Hype
  BASE_URL = 'http://hypem.com'

  class << self
    def latest(page = 1)
      process_feed "/feed/time/today/#{page}/feed.xml"
    end

    def popular_3days(page = 1)
      process_feed "/feed/popular/now/#{page}/feed.xml"
    end

    def popular_week(page = 1)
      process_feed "/feed/popular/lastweek/#{page}/feed.xml"
    end

    def user(username, page = 1)
      process_feed "/feed/loved/#{username}/#{page}/feed.xml"
    end

    def search(keyword, page = 1)   # TODO: url encoding needed?
      process_feed "/feed/search/#{keyword}/#{page}/feed.xml"
    end

    def default_http_session
      http = Patron::Session.new
      http.connect_timeout = 2
      http.timeout = 10
      http.base_url = BASE_URL
      http
    end

   private
    def process_feed(url)
      feed = Nokogiri::XML.parse(default_http_session.get(url).body)
      links = feed.search('item link').map { |tag| tag.text }
      links.map do |link|
        link =~ /track\/(.*)/
        Song.new($1)
      end
    end
  end


  class Song
    attr_accessor :id

    def initialize(id)
      @id = id

      @http = Hype.default_http_session
      @http.handle_cookies
      @http.timeout = 60
    end

    def artist
      fetch_info unless @artist
      @artist
    end

    def title
      fetch_info unless @title
      @title
    end

    def url
      fetch_info unless @url
      @url
    end

    def cover_url
      fetch_info unless @cover_url
      @cover_url
    end

   private
    def fetch_info
      # get the HypeM song detail page
      response = @http.get("/track/#{@id}?ax=1")
      doc = Nokogiri::HTML.parse(response.body)

      json = doc.search('script#displayList-data')[0]
      if not json
        @artist = nil
        @title = nil
        @cover_url = nil
      else
        info = ActiveSupport::JSON.decode(json)
        track = info['tracks'][0]
        @artist = track['artist']
        @title = track['song']
        @cover_url = doc.search('a.thumb').attr('style').text.match(/\(.+?\)/)[0][1..-2]

        url = "/serve/source/#{track['id']}/#{track['key']}"
        response2 = @http.get(url)
        doc2 = ActiveSupport::JSON.decode(response2.body)
        @url = doc2['url']
      end
    end
  end
end
