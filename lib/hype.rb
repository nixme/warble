require 'patron'
require 'nokogiri'
require 'execjs'

# TODO:
#  - replace V8 with execjs
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
        link =~ /item\/(.+?)\//
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

   private
    def fetch_info
      # get the HypeM song detail page
      response = @http.get("/item/#{@id}?ax=1")
      doc = Nokogiri::HTML.parse(response.body)

      # find the script tag with song info, and exec in V8 to grab info
      #   this might seem crazy, but it's the least fragile way to parse
      #   javascript object strings (no, JSON parsing won't work for
      #   non-stringified keys)
      canary = 'trackList[document.location.href].push'
      script = doc.search('script').find { |s| s && s.text[canary] }
      if !script  # TODO: replace with proper error handling
        @artist = @title = @url = ''
        return
      end
      info = js_context.eval(script.text.gsub(canary, 'identity'))
      @artist = info[:artist]
      @title  = info[:song]

      # follow redirects with current cookie for actual location of mp3
      @url = @http.head("/serve/play/#{@id}/#{info[:key]}.mp3").url

      # the javascript artist and title tags are sometimes truncated
      #  so attempt to scrape directly from DOM elements
      artist_element = doc.at_css('h3.track_name a.artist')
      if artist_element
        artist_dom_text = artist_element.text.strip
        @artist = artist_dom_text if artist_dom_text.length > @artist.length

        title_element = artist_element.next_element
        if title_element
          title_dom_text = title_element.text.strip
          @title = title_dom_text if title_dom_text.length > @title.length
        end
      end
    end

    def js_context
      return @@js_cxt if defined? @@js_cxt
      @@js_cxt = V8::Context.new
      @@js_cxt[:identity] = ->(x) { x }
      @@js_cxt
    end
  end
end
