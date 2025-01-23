require "open_graph_reader/object/registry"

module OpenGraphReader
  module Object
    # This module provides the methods to define new types and properties,
    # as well as setting other metadata necessary to describe an object, such
    # as its namespace.
    module DSL
      # @!macro define_type_description
      #   @param [Symbol] name the name of the property in the current namespace
      #   @param [{Symbol => Bool, Class, Array<String>}] options additional options
      #   @option options [Bool] :required (false) Make the property required.
      #   @option options [Bool] :collection (false) This property can occur multiple times.
      #   @option options [Class] :to This property maps to the given object (optional).
      #     belongs to the given verticals of the object (optional).
      #   @option options [Array<String>] :verticials This property
      #   @option options [Bool] :downcase (false) Normalize the contents case to lowercase.
      #
      # @!macro property
      #   @!attribute [rw] $1

      # @!macro [attach] define_type
      #   @!method $1(name, options={})
      #     @!macro define_type_description
      #
      # Defines a new DSL method for modeling a new type
      #
      # @yield  convert and validate
      # @yieldparam [::Object] value the value to be converted and validated
      # @yieldparam [Array<::Object>] *args any additional arguments
      # @yieldparam [{Symbol => Bool, Class, Array<String>}] options the options hash as last parameter
      def self.define_type(name, &processor)
        processors[name] = processor

        define_method(name) do |name, *args|
          options = args.pop if args.last.is_a? Hash
          options ||= {}

          register_property name, options
          register_verticals name, options[:verticals]

          if options[:collection]
            define_collection name, options
          else
            define_single name, options, args, processor
          end
        end
      end

      # @api private
      def register_property name, options
        available_properties << name.to_s
        required_properties << name.to_s if options[:required]
        Registry.register [namespace, name].join(":"), options[:to] if options[:to]
      end

      # @api private
      def register_verticals name, assigned_verticals
        [*assigned_verticals].each do |vertical|
          vertical = [namespace, vertical].join(".")
          verticals[vertical] << name.to_s
          Registry.verticals << vertical
        end
      end

      # @api private
      def define_collection name, options
        define_method("#{name}s") do
          children[name.to_s]
        end

        define_method(name) do
          value = children[name.to_s].first
          # @todo figure out a sane way to distinguish subobject properties
          value.content if value&.is_a?(Object)
          value || options[:default]
        end
      end

      # @api private
      def define_single name, options, args, processor
        define_method(name) do
          properties[name.to_s] || options[:default]
        end

        define_method("#{name}=") do |value|
          # @todo figure out a sane way to distinguish subobject properties
          unless value.is_a? Object
            value.downcase! if options[:downcase]
            value = processor.call(value, *args, options)
          end
          properties[name.to_s] = value
        end
      end

      # Alias to trick YARD
      singleton_class.send(:alias_method, :define_type_no_doc, :define_type)

      # The processor for the content attribute.
      #
      # @api private
      # @return [Proc]
      attr_reader :content_processor

      # @overload namespace
      #   Get the namespace of this object.
      #
      #   @return [String] A colon separated namespace, for example <tt>og:image</tt>.
      # @overload namespace(*names)
      #   Set the namespace of this object.
      #
      #   @param [Array<#to_s>] *names The individual parts of the namespace as list
      #   @example
      #     namespace :og, :image
      def namespace *names
        return @namespace if names.empty?
        @namespace = names.join(":")
        Registry.register @namespace, self
      end

      # @overload content type, *args, options={}
      #
      #   Set the type for the content attribute
      #
      #   @param [Symbol] type one of the registered types.
      #   @param [Array<Object>] args Additional parameters for the type
      #   @param [Hash] options
      #   @option options [Bool] :downcase (false) Normalize the contents case to lowercase.
      def content type, *args
        options = args.pop if args.last.is_a? Hash
        options ||= {}

        @content_processor = proc { |value|
          value.downcase! if options[:downcase]
          options[:to] ||= self
          DSL.processors[type].call(value, *args, options)
        }
      end

      # The list of defined properties on this object.
      #
      # @return [Array<String>]
      def available_properties
        @available_properties ||= []
      end

      # The list of required properties on this object.
      #
      # @return [Array<String]
      def required_properties
        @required_properties ||= []
      end

      # A map from type names to processing blocks.
      #
      # @api private
      # @return [{Symbol => Proc}]
      def self.processors
        @processors ||= {}
      end

      # A map from vertical names to attributes that belong to them.
      #
      # @api private
      # @return [{String => Array<Strin>}]
      def verticals
        @verticals ||= Hash.new { |h, k| h[k] = [] }
      end
    end
  end
end
