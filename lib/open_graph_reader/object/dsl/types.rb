require "date"
require "uri"

require "open_graph_reader/object/dsl"

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

        next value if value.start_with?("http://") || value.start_with?("https://")

        if options[:image] && OpenGraphReader.config.synthesize_image_url || OpenGraphReader.config.synthesize_url
          unless OpenGraphReader.current_origin
            next unless options[:required] || !OpenGraphReader.config.discard_invalid_optional_properties

            raise ArgumentError, "Enabled image url synthesization but didn't pass an origin"
          end

          # Synthesize scheme hack to https (//example.org/foo/bar.png)
          next "https:#{value}" if value.start_with?("//") && value.split("/", 4)[2] =~ URI::HOST

          # Synthesize absolute path (/foo/bar.png)
          begin
            value = "/#{value}" unless value.start_with? "/" # Normalize to absolute path
            uri = URI.parse(OpenGraphReader.current_origin)
            uri.path = value
            value = uri.to_s
          rescue
            next unless options[:required] || !OpenGraphReader.config.discard_invalid_optional_properties
            raise InvalidObjectError,
                  "URL #{value.inspect} does not start with http:// or https:// and failed to "\
                  "synthesize a full URL"
          end
        elsif options.has_key?(:to) && OpenGraphReader.config.validate_references
          next unless options[:required] || !OpenGraphReader.config.discard_invalid_optional_properties
          raise InvalidObjectError, "URL #{value.inspect} does not start with http:// or https://"
        end

        value
      end

      # @!method enum(name, allowed, options={})
      #   @param [Array<String>] allowed the list of allowed values
      #   @!macro define_type_description
      #   @see http://ogp.me/#enum
      define_type_no_doc :enum do |value, allowed, options|
        value = value.to_s

        unless allowed.include? value
          next unless options[:required] || !OpenGraphReader.config.discard_invalid_optional_properties
          raise InvalidObjectError, "Expected one of #{allowed.inspect} but was #{value.inspect}"
        end

        value
      end

      # @see http://ogp.me/#integer
      define_type :integer do  |value, options|
        begin
          Integer(value)
        rescue ArgumentError
          next unless options[:required] || !OpenGraphReader.config.discard_invalid_optional_properties
          raise InvalidObjectError, "Integer expected, but was #{value.inspect}"
        end
      end

      # @see http://ogp.me/#datetime
      define_type :datetime do |value, options|
        begin
          if OpenGraphReader.config.guess_datetime_format
            DateTime.parse value
          else
            DateTime.iso8601 value
          end
        rescue ArgumentError
          next unless options[:required] || !OpenGraphReader.config.discard_invalid_optional_properties
          raise InvalidObjectError, "ISO8601 datetime expected, but was #{value.inspect}"
        end
      end

      # @see http://ogp.me/#bool
      define_type :boolean do |value, options|
        {"true" => true, "false" => false, "1" => true, "0" => false}[value].tap {|bool|
          if bool.nil?
            next unless options[:required] || !OpenGraphReader.config.discard_invalid_optional_properties
            raise InvalidObjectError, "Boolean expected, but was #{value.inspect}"
          end
        }
      end

      # @see http://ogp.me/#float
      define_type :float do |value, options|
        begin
          Float(value)
        rescue ArgumentError
          next unless options[:required] || !OpenGraphReader.config.discard_invalid_optional_properties
          raise InvalidObjectError, "Float expected, but was #{value.inspect}"
        end
      end
    end
  end
end
