module OpenGraphReader
  # Convert a {Parser::Graph} into the right hierarchy of {Object}s attached
  # to a {Base}, then validate it.
  #
  # @api private
  class Builder
    # Well-known types from
    #
    # @see http://ogp.me
    KNOWN_TYPES = %w[website article book profile].freeze

    # Create a new builder.
    #
    # @param [Parser] parser
    # @see Parser#graph
    # @see Parser#additional_namespaces
    def initialize parser
      @parser = parser
    end

    # Build and return the base.
    #
    # @return [Base]
    def base
      base = Base.new

      type = @parser.graph.fetch("og:type", "website").downcase

      validate_type type

      @parser.graph.each do |property|
        build_property base, property
      end

      synthesize_required_properties base
      drop_empty_children base
      validate base

      base
    end

    private

    def build_property base, property
      object, name = object_and_name base, property

      if collection? object, name
        build_collection object, property, name
      elsif subobject? property
        build_subobject object, property, name
      else # Direct attribute
        build_single object, property, name
      end
    rescue UnknownNamespaceError, UndefinedPropertyError => e
      raise InvalidObjectError, e.message if OpenGraphReader.config.strict
    end

    def object_and_name base, property
      root, *path, name = property.path
      base[root] ||= Object::Registry[root].new
      object = resolve base[root], root, path

      [object, name]
    end

    def collection? object, name
      object.property?(name) && object.respond_to?("#{name}s")
    end

    def build_collection object, property, name
      collection = object.public_send "#{name}s"
      if Object::Registry.registered? property.fullname # of subobjects
        object = Object::Registry[property.fullname].new
        collection << object
        object.content = property.content
      else # of type
        collection << property.content
      end
    end

    def subobject? property
      Object::Registry.registered? property.fullname
    end

    def build_subobject object, property, name
      object[name] ||= Object::Registry[property.fullname].new
      object[name].content = property.content
    end

    def build_single object, property, name
      object[name] = property.content
    end

    def resolve object, last_namespace, path
      return object if path.empty?

      next_name = path.shift
      if object.property?(next_name) && object.respond_to?("#{next_name}s") # collection
        resolve_collection object, last_namespace, next_name
      else
        resolve_property object, last_namespace, next_name
      end
    end

    def resolve_collection object, last_namespace, next_name
      collection = object.public_send("#{next_name}s")
      next_object = collection.last
      # Final namespace or missing previous declaration, create a new collection item
      if next_object.nil?
        next_object = Object::Registry[[*last_namespace, next_name].join(":")].new
        collection << next_object
      end

      next_object
    end

    def resolve_property object, last_namespace, next_name
      next_object = object[next_name]
      next_object || Object::Registry[[*last_namespace, next_name].join(":")].new
    end

    def synthesize_required_properties base
      synthesize_url base
      synthesize_title base
      synthesize_image_content base
    end

    def synthesize_url base
      return unless OpenGraphReader.config.synthesize_url
      return if base.og.url

      base.og["url"] = OpenGraphReader.current_origin
    end

    def synthesize_title base
      return unless OpenGraphReader.config.synthesize_title
      return if base.og.title

      base.og["title"] = @parser.title
    end

    def synthesize_image_content base
      return unless OpenGraphReader.config.synthesize_image_content
      return unless base.og.image
      return if base.og.image.content || base.og.image.url.nil?

      base.og.image.content = base.og.image.url
    end

    def drop_empty_children base
      base = base.children
      base.each do |key, object|
        [*object].each do |object|
          if object.is_a? Object
            drop_empty_children object
            base.delete(key) if object.content.nil? && object.children.empty? && object.properties.empty?
          end
        end
      end
    end

    def validate_type type
      return unless OpenGraphReader.config.strict

      return if KNOWN_TYPES.include?(type)
      return if @parser.additional_namespaces.include?(type)
      return if Object::Registry.verticals.include?(type)

      raise InvalidObjectError, "Undefined type #{type}"
    end

    def validate base
      base.each do |object|
        validate_required object if OpenGraphReader.config.validate_required
        validate_verticals object, base.og.type
      end
    end

    def validate_required object
      object.class.required_properties.each do |property|
        if object[property].nil?
          raise InvalidObjectError, "Missing required property #{property} on #{object.inspect}"
        end
      end
    end

    def validate_verticals object, type
      return unless type.include? "."

      verticals = object.class.verticals
      return unless verticals.has_key? type
      return if extra_properties(object, type, verticals).empty?

      raise InvalidObjectError, "Set invalid property #{extra_properties.first} for #{type} " \
        "in #{object.inspect}, valid properties are #{valid_properties.inspect}"
    end

    def extra_properties object, type, verticals
      valid_properties = verticals[type]
      set_properties = object.class.available_properties.select { |property| object[property] }

      set_properties - valid_properties
    end
  end
end
