require 'uri'

require 'open_graph_reader/base'
require 'open_graph_reader/builder'
require 'open_graph_reader/configuration'
require 'open_graph_reader/definitions'
require 'open_graph_reader/fetcher'
require 'open_graph_reader/object'
require 'open_graph_reader/parser'
require 'open_graph_reader/version'

# @todo  quirks mode where invalid attributes don't raise?
# @todo 1.1 compatibility mode?
# This module provides the main entry to the library. Please see the
# {file:README.md} for usage examples.
module OpenGraphReader
  # Fetch the OpenGraph object at the given URL. Raise if there are any issues.
  #
  # @param [URI,#to_s] url The URL of the OpenGraph object to retrieve.
  # @return [Base] The base object from which you can obtain the root objects.
  # @raise [NoOpenGraphDataError] {include:NoOpenGraphDataError}
  # @raise [InvalidObjectError] {include:InvalidObjectError}
  def self.fetch! url
    case url
    when URI
      target = Fetcher.new(url)
      raise NoOpenGraphDataError, "#{url} doesn't contain any HTML" unless target.html?
      parse! target.body, target.url
    else
      fetch! URI.parse(url.to_s)
    end
  end

  # Parse the OpenGraph object in the given HTML document. Raise if there are any issues.
  #
  # @param [#to_s, Nokogiri::XML::Node] html A HTML document that contains an OpenGraph object.
  # @param [#to_s] origin The source from where the given document was fetched.
  # @return [Base] The base object from which you can obtain the root objects.
  # @raise [NoOpenGraphDataError] {include:NoOpenGraphDataError}
  # @raise [InvalidObjectError] {include:InvalidObjectError}
  def self.parse! html, origin=nil
    parser = Parser.new html
    raise NoOpenGraphDataError, "#{origin || html} does not contain any OpenGraph tags" unless parser.has_tags?
    Builder.new(parser.graph, parser.additional_namespaces).base.tap {|base|
      base.origin = origin.to_s if origin
    }
  end

  # Convenience wrapper around {OpenGraphReader.fetch!} that swallows the esceptions
  # and returns nil instead.
  #
  # @param [URI,#to_s] url The URL of the OpenGraph object to retrieve.
  # @return [Base, nil] The base object from which you can obtain the root objects.
  # @see OpenGraphReader.fetch!
  def self.fetch url
    fetch! url
  rescue NoOpenGraphDataError, InvalidObjectError
  end

  # Convenience wrapper around {OpenGraphReader.parse!} that swallows the esceptions
  # and returns nil instead.
  #
  # @param [#to_s] html A HTML document that contains an OpenGraph object.
  # @param [#to_s] origin The source from where the given document was fetched.
  # @return [Base, nil] The base object from which you can obtain the root objects.
  # @see OpenGraphReader.parse!
  def self.parse html, origin=nil
    parse! html, origin
  rescue NoOpenGraphDataError, InvalidObjectError
  end

  # Configure the library, see {Configuration} for the list of available
  # options and their defaults. Changing configuration at runtime is not
  # thread safe.
  #
  # @yieldparam [Configuration] the configuration object
  # @see Configuration
  def self.configure
    yield config
  end

  # Get the current {Configuration} instance
  #
  # @api private
  # @return [Configuration]
  def self.config
    Configuration.instance
  end

  # The target couldn't be fetched, didn't contain any HTML or
  # any OpenGraph tags.
  class NoOpenGraphDataError < StandardError
  end

  # The target did contain OpenGraph tags, but they're not valid.
  class InvalidObjectError < StandardError
  end
end
