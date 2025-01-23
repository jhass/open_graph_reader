require "faraday"

begin
  require "faraday/follow_redirects"
rescue LoadError; end

begin
  require "faraday/cookie_jar"
rescue LoadError; end

require "open_graph_reader/version"

module OpenGraphReader
  # Fetch an URI to retrieve its HTML body, if available.
  #
  # @api private
  class Fetcher
    HEADERS = {
      "Accept" => "text/html",
      "User-Agent" => "OpenGraphReader/#{OpenGraphReader::VERSION} (+https://github.com/jhass/open_graph_reader)"
    }.freeze

    # Create a new fetcher.
    #
    # @param [URI] uri the URI to fetch.
    def initialize uri
      raise ArgumentError, "url needs to be an instance of URI" unless uri.is_a? URI

      @uri = uri
      @fetch_failed = false
      @connection = Faraday.default_connection.dup
      @connection.headers.replace(HEADERS)
      @head_response = nil
      @get_response = nil

      prepend_middleware Faraday::CookieJar if defined? Faraday::CookieJar
      prepend_middleware Faraday::FollowRedirects::Middleware if defined? Faraday::FollowRedirects
    end

    # The URL to fetch
    #
    # @return [String]
    def url
      @uri.to_s
    end

    # Fetch the full page.
    #
    # @return [Faraday::Response,nil]
    def fetch
      @get_response = @connection.get(@uri)
    rescue Faraday::Error
      @fetch_failed = true
    end
    alias fetch_body fetch

    # Fetch just the headers
    #
    # @return [Faraday::Response,nil]
    def fetch_headers
      @head_response = @connection.head(@uri)
    rescue Faraday::Error
      @fetch_failed = true
    end

    # Retrieve the body
    #
    # @todo Custom error class
    # @raise [ArgumentError] The received content does not seems to be HTML.
    # @return [String]
    def body
      fetch_body unless fetched?
      raise NoOpenGraphDataError, "No response body received for #{@uri}" if fetch_failed?
      raise NoOpenGraphDataError, "Did not receive a HTML site at #{@uri}" unless html?

      @get_response.body
    end

    # Whether the target URI seems to return HTML
    #
    # @return [Bool]
    def html?
      fetch_headers unless fetched_headers?
      response = @get_response || @head_response
      return false if fetch_failed?
      return false unless response
      return false unless response.success?
      return false unless response["content-type"]

      response["content-type"].include? "text/html"
    end

    # Whether the target URI was fetched.
    #
    # @return [Bool]
    def fetched?
      fetch_failed? || !@get_response.nil?
    end
    alias fetched_body? fetched?

    # Whether the headers of the target URI were fetched.
    #
    # @return [Bool]
    def fetched_headers?
      fetch_failed? || !@get_response.nil? || !@head_response.nil?
    end

    private

    def fetch_failed?
      @fetch_failed
    end

    def prepend_middleware middleware
      return if @connection.builder.handlers.include? middleware

      @connection.builder.insert(0, middleware)
    end
  end
end
