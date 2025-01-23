require "singleton"
require "forwardable"

module OpenGraphReader
  module Object
    # Global registry of namespaces and their representing classes.
    # Also tracks which verticals are defined.
    #
    # @api private
    class Registry
      extend Forwardable
      include Singleton

      class << self
        extend Forwardable
        # @!method register(namespace, klass)
        #   Register a new namespace in the registry.
        #
        #   @param [String] namespace The namespace in colon separated form, for example <tt>og:image</tt>.
        #   @param [Class] klass The class to register. It should include {Object}.
        #   @api private
        #
        # @!method registered?(namespace)
        #   Check whether a namespace is registered.
        #
        #   @param [String] namespace The namespace in colon separated form, for example <tt>og:image</tt>.
        #   @return [Bool]
        #   @api private
        #
        # @!method [](namespace)
        #   Fetch the class associated with the given namespace
        #
        #   @param [String] namespace The namespace in colon separated form, for example <tt>og:image</tt>.
        #   @return [Class] The matching class.
        #   @raise [ArgumentError] If the given namespace wasn't registered.
        #   @api private
        # @!method verticals
        #  All known verticals
        #
        #  @return [Set<String>]
        def_delegators :instance, :register, :registered?, :[], :verticals
      end

      def_delegators :@namespaces, :[]=, :has_key?
      alias_method :register, :[]=
      alias_method :registered?, :has_key?

      # @see Registry.verticals
      attr_reader :verticals

      def initialize
        @namespaces = {}
        @verticals = Set.new
      end

      # @see Registry.[]
      def [] namespace
        raise UnknownNamespaceError, "#{namespace} is not a registered namespace" unless registered? namespace
        @namespaces[namespace]
      end
    end
  end
end
