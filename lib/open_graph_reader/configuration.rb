require 'singleton'

module OpenGraphReader
  # The behavior of this library can be tweaked with some parameters.
  #
  # @example
  #   OpenGraphReader.configure do |config|
  #     config.strict = true
  #   end
  class Configuration
    include Singleton

    # Strict mode (default: <tt>false</tt>)
    #
    # In strict mode, if the fetched site defines an unknown type
    # or property, {InvalidObjectError} is thrown instead of just ignoring
    # those.
    #
    # @return [Bool]
    attr_accessor :strict

    # Validate required (default: <tt>true</tt>)
    #
    # Validate that required properties exist. If this is enabled and
    # they do not,  {InvalidObjectError} is thrown.
    #
    # @return [Bool]
    attr_accessor :validate_required

    # Validate references (default: <tt>true</tt>)
    #
    # If an object should be a reference to another object,
    # validate that it contains an URL. Be careful in turning this off,
    # an attacker could place things like <tt>javascript:</tt> links there.
    #
    # @return [Bool]
    attr_accessor :validate_references

    # @private
    def initialize
      reset_to_defaults!
    end

    # Reset configuration to their defaults
    def reset_to_defaults!
      @strict = false
      @validate_required = true
      @validate_references = true
    end
  end
end
