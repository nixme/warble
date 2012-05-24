class PandoraRetryingClient
  attr_reader :client

  def initialize(client)
    @client = client
  end

  # Forward all method calls to the actual
  def method_missing(method, *args, &block)
    retries = 1
    begin
      @client.__send__(method, *args, &block)
    rescue Pandora::APIError
      @client.reauthenticate
      retry if (retries -= 1) >= 0
    end
  end
end
