require 'date'
require 'uri'

require 'open_graph_reader/object/dsl'

module OpenGraphReader
  module Object
    module DSL
      # @see http://ogp.me/#string
      define_type :string do |value|
        value.to_s
      end

      # @!method url(name, options={})
      #   @option options [Bool] :image (false) Mark attribute as image to be eligible
      #     for URL synthesization. See {Configuration#synthesize_image_url}.
      #   @!macro define_type_description
      #   @see http://ogp.me/#url
      define_type_no_doc :url do |value, options|
        value = value.to_s

        unless value.start_with?('http://') || value.start_with?('https://')
          if options[:image] && OpenGraphReader.config.synthesize_image_url
            unless OpenGraphReader.current_origin
              raise ArgumentError, "Enabled image url synthesization but didn't pass an origin"
            end

            # Synthesize scheme hack to https (//example.org/foo/bar.png)
            if value.start_with?('//') && value.split('/', 4)[2] =~ URI::HOST
              value = "https:#{value}"
            else # Synthesize absolute path (/foo/bar.png)
              begin
                value = "/#{value}" unless value.start_with? '/' # Normalize to absolute path
                uri = URI.parse(OpenGraphReader.current_origin)
                uri.path = value
                value = uri.to_s
              rescue
                raise InvalidObjectError, "URL #{value.inspect} does not start with http:// or https:// and failed to synthesize a full URL"
              end
            end
          elsif options.has_key?(:to) && OpenGraphReader.config.validate_references
            raise InvalidObjectError, "URL #{value.inspect} does not start with http:// or https://"
          end
        end

        value
      end

      # @!method enum(name, allowed, options={})
      #   @param [Array<String>] allowed the list of allowed values
      #   @!macro define_type_description
      #   @see http://ogp.me/#enum
      define_type_no_doc :enum do |value, allowed|
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
