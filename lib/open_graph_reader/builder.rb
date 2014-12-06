module OpenGraphReader
  # Convert a {Parser::Graph} into the right hierarchy of {Object}s attached
  # to a {Base}.
  #
  # @todo validate required, verticals
  # @api private
  class Builder
    # Well-known types from
    #
    # @see http://ogp.me
    KNOWN_TYPES = %w(
      website
      music.song
      music.album
      music.playlist
      music.radio_station
      video.movie
      video.episode
      video.tv_show
      video.other
      article
      book
      profile
    ).freeze

    # Create a new builder.
    #
    # @param [Parser::Graph] graph
    # @param [Array<String>] additional_namespaces Namespaces found in the
    #   prefix attribute of the head tag of the HTML document
    # @see Parser#graph
    # @see Parser#additional_namespaces
    def initialize graph, additional_namespaces=[]
      @graph = graph
      @additional_namespaces = additional_namespaces
    end

    # Build and return the base.
    #
    # @return [Base]
    def base
      base = Base.new

      type = @graph.fetch 'og:type', 'website'

      validate_type type

      @graph.each do |property|
        root, *path, name = property.path
        base[root] ||= Object::Registry[root].new
        object = resolve base[root], root, path

        if object.respond_to? "#{name}s" # Collection # TODO
          collection = object.public_send "#{name}s" #TODO
          if Object::Registry.registered? property.fullname # of subobjects
            object = Object::Registry[property.fullname].new
            collection << object
            object.content = property.content
          else # of type
            collection << property.content
          end
        elsif Object::Registry.registered? property.fullname # Subobject
          object[name] ||= Object::Registry[property.fullname].new
          object[name].content = property.content
        else # Direct attribute
          object[name] = property.content
        end
      end

      base
    end

    private

    def resolve object, last_namespace, path
      return object if path.empty?

      next_name = path.shift
      if object.respond_to? "#{next_name}s" # collection # TODO: do not respond_to? with user data
        collection = object.public_send("#{next_name}s") # TODO: do not public_send with user data
        next_object = collection.last
        if next_object.nil? #|| path.empty? # Final namespace or missing previous declaration, create a new collection item
          next_object = Object::Registry[[*last_namespace, next_name].join(':')].new
          collection << next_object
        end
      else
        next_object = object[next_name]
        next_object ||= Object::Registry[[*last_namespace, next_name].join(':')].new
      end

      next_object
    end

    def validate_type type
      unless KNOWN_TYPES.include?(type) || @additional_namespaces.include?(type)
        raise InvalidObjectError, "Undefined type #{type}"
      end
    end
  end
end
