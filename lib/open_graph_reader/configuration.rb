require 'singleton'

module OpenGraphReader
  # The behavior of this library can be tweaked with some parameters.
  # Note that configuration is global, changing it at runtime is not
  # thread safe.
  #
  # @example
  #   OpenGraphReader.configure do |config|
  #     config.strict = true
  #   end
  class Configuration
    include Singleton

    # Strict mode (default: <tt>false</tt>).
    #
    # In strict mode, if the fetched site defines an unknown type
    # or property, {InvalidObjectError} is thrown instead of just ignoring
    # those.
    #
    # @return [Bool]
    attr_accessor :strict

    # Validate required (default: <tt>true</tt>).
    #
    # Validate that required properties exist. If this is enabled and
    # they do not,  {InvalidObjectError} is thrown.
    #
    # @return [Bool]
    attr_accessor :validate_required

    # Validate references (default: <tt>true</tt>).
    #
    # If an object should be a reference to another object,
    # validate that it contains an URL. Be careful in turning this off,
    # an attacker could place things like <tt>javascript:</tt> links there.
    #
    # @return [Bool]
    attr_accessor :validate_references

    # Discard invalid optional properties (default: <tt>false</tt>).
    #
    # Instead of rendering the entire object invalid, discard
    # invalid optional properties.
    #
    # @return [Bool]
    attr_accessor :discard_invalid_optional_properties

    # Fallback to the title tag if og:title is missing (default: <tt>false</tt>).
    #
    # The standard makes defining og:title required, but it's
    # a common practice to rely on the parser falling back to
    # synthesize it from the title tag. This option enables this feature.
    #
    # @return [Bool]
    attr_accessor :synthesize_title

    # Guess image URL when it looks like a path (default: <tt>false</tt>).
    #
    # The standard requires og:image, og:image:url and og:image:secure_url
    # to be a full URL. However it's common practice to put a path relative
    # to the domain URL. When enabled, the library tries to guess the full
    # URL from such a path. Note the object can still turn invalid if it fails
    # to do so.
    #
    # @return [Bool]
    attr_accessor :synthesize_image_url

    # @private
    def initialize
      reset_to_defaults!
    end

    # Reset configuration to their defaults
    def reset_to_defaults!
      @strict                              = false
      @validate_required                   = true
      @validate_references                 = true
      @discard_invalid_optional_properties = false
      @synthesize_title                    = false
      @synthesize_image_url                = false
    end
  end
end
