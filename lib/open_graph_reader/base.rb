require "forwardable"

module OpenGraphReader
  # You get an instance of this class as result of your quest to obtain
  # an OpenGraph object. It simply contains and returns the root objects,
  # most commonly <tt>og</tt>.
  class Base
    extend Forwardable

    # @!method [](name)
    #   Get a root object by name.
    #
    #   @param [String] name The name of the root namespace.
    #   @return [Object, nil] The corresponding root object if available.
    #   @api private
    # @!method []=(name, object)
    #   Make a new root object available on this base.
    #
    #   @param [String] name The name of the root namespace.
    #   @param [Object] object The corresponding root object.
    #   @api private
    # @!method each
    #   Traverse the available objects
    #
    #   @yield [Object]
    #   @api private
    def_delegators :@bases, :[], :[]=, :each_value
    alias_method :each, :each_value

    # If available, contains the source location of the document the
    # available objects were parsed from.
    #
    # @return [String, nil]
    attr_reader :origin

    # Set origin.
    #
    # @api private
    # @see #origin
    attr_writer :origin

    # Return the stored root objects as a hash.
    #
    # @api private
    # @return [String => Object]
    attr_reader :bases
    alias_method :children, :bases

    # @api private
    def initialize
      @bases = {}
    end

    # @private
    def respond_to_missing?(method, _include_private = false)
      @bases.has_key? method.to_s
    end

    # Makes the found root objects available.
    # @return [Object]
    def method_missing(method, *, &)
      name = method.to_s
      if respond_to_missing? name
        @bases[name]
      else
        super(method, *, &)
      end
    end
  end
end
