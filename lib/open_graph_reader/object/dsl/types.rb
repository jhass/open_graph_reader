require 'date'

require 'open_graph_reader/object/dsl'

module OpenGraphReader
  module Object
    module DSL
      # @see http://ogp.me/#string
      define_type :string do |value|
        value.to_s
      end

      # @see http://ogp.me/#url
      define_type :url do |value, options|
        value.to_s.tap {|value|
          unless value.start_with?('http://') || value.start_with?('https://')
             if options.has_key?(:to) && OpenGraphReader.config.validate_references
              raise InvalidObjectError, "URL #{value.inspect} does not start with http:// or https://"
            end
          end
        }
      end

      # @!method enum(name, allowed, options={})
      #   @param [Array<String>] allowed the list of allowed values
      #   @!macro define_type_description
      # @see http://ogp.me/#enum
      define_type_with_args :enum do |value, allowed|
        unless allowed.include? value
          raise InvalidObjectError, "Expected one of #{allowed.inspect} but was #{value.inspect}"
        end

        value.to_s
      end

      # @see http://ogp.me/#integer
      define_type :integer do  |value|
        begin
          Integer(value)
        rescue  ArgumentError => e
          raise InvalidObjectError, "Integer expected, but was #{value.inspect}"
        end
      end

      # @see http://ogp.me/#datetime
      define_type :datetime do |value|
        begin
          DateTime.iso8601 value
        rescue ArgumentError => e
          raise InvalidObjectError, "ISO8601 datetime expected, but was #{value.inspect}"
        end
      end

      # @see http://ogp.me/#bool
      define_type :boolean do |value|
        {'true' => true, 'false' => false, '1' => true, '0' => false}[value].tap {|bool|
          if bool.nil?
            raise InvalidObjectError, "Boolean expected, but was #{value.inspect}"
          end
        }
      end

      # @see http://ogp.me/#float
      define_type :float do |value|
        begin
          Float(value)
        rescue ArgumentError => e
          raise InvalidObjectError, "Float expected, but was #{value.inspect}"
        end
      end
    end
  end
end
