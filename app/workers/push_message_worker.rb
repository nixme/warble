class PushMessageWorker
  include Sidekiq::Worker

  sidekiq_options queue: :push


  class << self; alias :message :perform_async; end

  def perform(data)
    body = {
      channel: '/global',
      data:    data
    }

    response = connection.post do |request|
      request.body = { message: body.to_json }
    end

    raise 'Error sending message to push server' unless response.success?
  end


 private

  def connection
    # TODO: Currently assumes push server on same machine. Unhardcode
    @connection ||= Faraday.new(url: 'http://127.0.0.1:9292') do |builder|
      builder.request :url_encoded
      builder.use     :instrumentation
      builder.adapter :net_http
    end
  end
end
