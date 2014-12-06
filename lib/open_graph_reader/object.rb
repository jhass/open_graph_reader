require 'open_graph_reader/object/registry'
require 'open_graph_reader/object/dsl'
require 'open_graph_reader/object/dsl/types'

module OpenGraphReader

  # This module provides the base functionality for all OpenGraph objects
  # and makes the {DSL} methods for describing them available when included.
  #
  # @example Define a new object
  #   class MyObject
  #     include OpenGraphReader::Object
  #
  #      namespace :my, :object
  #      content :string
  #      string :name, required: true
  #   end
  module Object
    # @private
    def self.included base
      base.extend DSL
    end

    # If the namespace this object represents had a value, it is available here
    # @return [String, nil]
    attr_reader :content

    # Regular properties on this object
    #
    # @api private
    # @return [{String => String, Object}]
    attr_reader :properties

    # Properties on this object that are arrays.
    #
    # @api private
    # @return [{String => Array<String, Object>}]
    attr_reader :children


    # Create a new object. If your class overrides this don't forget to call <tt>super</tt>.
    def initialize
      @properties = {}
      @children = Hash.new {|h, k| h[k] = [] }
    end

    # Whether this object has the given property
    #
    # @param [#to_s] name
    # @return [Bool]
    def has_property? name
      self.class.available_properties.include? name.to_s
    end

    # Set the content for this object in case it is also a property on
    # another object. If a processor is defined, it will be called.
    #
    # @api private
    # @param [String] value
    def content= value
      value = self.class.content_processor.call(value)
      @content = value
    end

    # Get a property on this object.
    #
    # @api private
    # @param [#to_s] name
    # @todo right error?
    # @raise [InvalidObjectError] If the requested property is undefined.
    # @return [String, Object]
    def [] name
      raise InvalidObjectError, "Undefined property #{name} on #{inspect}" unless has_property? name
      properties[name.to_s]
    end

    # Set the property to the given value.
    #
    # @api private
    # @param [#to_s] name
    # @param [String, Object] value
    # @raise [InvalidObjectError] If the requested property is undefined.
    def []= name, value
      raise InvalidObjectError, "Undefined property #{name} on #{inspect}" unless has_property? name
      public_send "#{name}=", value
    end

    # Returns {#content} if available.
    #
    # @return [String]
    def to_s
      content || super
    end
  end
end
