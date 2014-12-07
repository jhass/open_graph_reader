require 'faraday'

begin
  require 'faraday_middleware/response/follow_redirects'
rescue LoadError; end

begin
  require 'faraday/cookie_jar'
rescue LoadError; end

module OpenGraphReader
  # Fetch an URI to retrieve its HTML body, if available.
  #
  # @api private
  class Fetcher
    # Create a new fetcher.
    #
    # @param [URI] uri the URI to fetch.
    def initialize uri
      raise ArgumentError, "url needs to be an instance of URI" unless uri.is_a? URI
      @uri = uri
      @connection = Faraday.default_connection.dup

      if defined? FaradayMiddleware
        prepend_middleware FaradayMiddleware::FollowRedirects
      end

      if defined? Faraday::CookieJar
        prepend_middleware Faraday::CookieJar
      end
    end

    # The URL to fetch
    #
    # @return [String]
    def url
      @uri.to_s
    end

    # Fetch the full page.
    #
    # @return [Faraday::Response]
    def fetch
      @get_response = @connection.get(@uri)
    end
    alias_method :fetch_body, :fetch

    # Fetch just the headers
    #
    # @return [Faraday::Response]
    def fetch_headers
      @head_response = @connection.head(@uri)
    end

    # Retrieve the body
    #
    # @todo Custom error class
    # @raise [ArgumentError] The received content does not seems to be HTML.
    # @return [String]
    def body
      fetch_body unless fetched?
      raise ArgumentError, "Did not receive a HTML site at #{@uri}" unless html?
      @get_response.body
    end

    # Whether the target URI seems to return HTML
    #
    # @return [Bool]
    def html?
      fetch_headers unless fetched_headers?
      response = @get_response || @head_response
      return false unless response.success?
      return false unless response['content-type']
      response['content-type'].include? 'text/html'
    end

    # Whether the target URI was fetched.
    #
    # @return [Bool]
    def fetched?
      !@get_response.nil?
    end
    alias_method :fetched_body?, :fetched?

    # Whether the headers of the target URI were fetched.
    #
    # @return [Bool]
    def fetched_headers?
      !@get_response.nil? || !@head_response.nil?
    end

    private

    def prepend_middleware middleware
      unless @connection.builder.handlers.include? middleware
          @connection.builder.insert(0, middleware)
      end
    end
  end
end
