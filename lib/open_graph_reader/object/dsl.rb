require 'open_graph_reader/object/registry'

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
          available_properties << name.to_s
          options = args.pop if args.last.is_a? Hash
          options ||= {}

          Registry.register [@namespace, name].join(':'), options[:to] if options[:to]

          if options[:verticals]
            options[:verticals].each do |vertical|
              verticals[[@namespace, vertical].join('.')] << name
            end
          end

          if options[:collection]
            define_method("#{name}s") do
              children[name.to_s]
            end

            define_method(name) do
              # TODO raise if required
              value = children[name.to_s].first
              # TODO: figure out a sane way to distinguish subobject properties
              value.content if value && value.is_a?(Object)
              value || options[:default]
            end
          else
            define_method(name) do
              # TODO raise if required
              properties[name.to_s] || options[:default]
            end

            define_method("#{name}=") do |value|
              # TODO: figure out a sane way to distinguish subobject properties
              value = processor.call(value, *args, options) unless value.is_a? Object
              properties[name.to_s] = value
            end
          end
        end
      end
      singleton_class.send(:alias_method, :define_type_with_args, :define_type)

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
        @namespace = names.join(':')
        Registry.register @namespace, self
      end

      # Set the type for the content attribute
      #
      # @param [Symbol] type one of the registered types.
      def content type
        @content_processor = DSL.processors[type]
      end

      # The list of defined properties on this object.
      #
      # @return [Array<String>]
      def available_properties
        @available_properties ||= []
      end

      # A map from type names to processing blocks.
      #
      # @api private
      # @return [{Symbol => Proc}]
      def self.processors
        @processors ||= {}
      end

      # The processor for the content attribute.
      #
      # @api private
      # @return [Proc]
      def content_processor
        @content_processor || proc {|value| value }
      end

      # A map from vertical names to attributes that belong to them.
      #
      # @api private
      # @return [{String => Array<Strin>}]
      def verticals
        @verticals ||= Hash.new {|h, k| h[k] = [] }
      end
    end
  end
end
