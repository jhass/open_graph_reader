require "forwardable"

module OpenGraphReader
  class Parser
    # A Graph to represent OpenGraph tags.
    class Graph
      # A node in the graph.
      Node = Struct.new(:name, :content) do
        extend Forwardable
        include Enumerable

        # The parent node.
        #
        # @return [Node, nil]
        attr_accessor :parent

        # Does this node have any content or non-empty children?
        #
        # @return [Bool]
        def empty?
          content.nil? && (children.empty? || children.all?(&:empty?))
        end

        # Children of this node.
        def children
          @children ||= []
        end

        # Iterate over all children.
        #
        # @yield [Node]
        def each(&block)
          children.each do |child|
            yield child
            child.each(&block)
          end
        end

        # Add children.
        #
        # @param [Node] node
        def << node
          node.parent = self
          children << node
        end

        # Get node's namespace.
        #
        # @return [String]
        def namespace
          parent.fullname if parent
        end

        # Get node's namespace as array.
        #
        # @return [Array<String>]
        def path
          @path ||= fullname.split(":")
        end

        # Get node's full name.
        #
        # @return [String]
        def fullname
          @fullname ||= [namespace, name].compact.join(":")
          @fullname unless @fullname.empty?
        end

        def inspect
          "#{super.chop} children=#{children.inspect}>"
        end
        alias to_s inspect
      end

      extend Forwardable
      include Enumerable

      # The initial node.
      #
      # @return [Node, nil]
      attr_reader :root

      # @!method empty?
      #   Does this graph have any nodes?
      #
      #   @return [Bool]
      def_delegators :root, :empty?

      # Create new graph.
      def initialize
        @root = Node.new
      end

      # Iterate through all nodes that have a value.
      #
      # @yield [Node]
      def each
        root.each do |child|
          yield child if child.content
        end
      end

      # Whether the property exists in the graph. <tt>property</tt> doesn't have to
      # be a leave node but is only considered existing when there's a leaf node
      # with content below it.
      #
      # @param [String] property The fully qualified name, for example <tt>og:type</tt>
      #  or <tt>og</tt>.
      # @return [Bool] Whether the given property exists in the graph.
      def exist? property
        path = property.split(":")
        child = path.inject(root) {|node, name|
          node.children.find {|child| child.name == name } || break
        }
        !child.nil? && !child.empty?
      end

      # Fetch first node's value.
      #
      # @param [String] property The fully qualified name, for example <tt>og:type</tt>.
      # @param [String] default The default in case the a value is not found.
      # @yield Return a default in case the value is not found. Supersedes the default parameter.
      # @return [String, Bool, Integer, Float, DateTime, nil]
      def fetch property, default=nil
        node = find_by(property)
        return yield if node.nil? && block_given?
        return default if node.nil?
        node.content
      end

      # Fetch first node
      #
      # @param [String] property The fully qualified name, for example <tt>og:type</tt>.
      # @return [Node, nil]
      def find_by property
        property = normalize_property property
        find {|node| node.fullname == property }
      end

      # Fetch all nodes
      #
      # @param [String] property The fully qualified name, for example <tt>og:type</tt>.
      # @return [Array<Node>]
      def select_by property
        property = normalize_property property
        select {|node| node.fullname == property }
      end

      def find_or_create_path path
        path.inject(root) {|node, name|
          child = node.children.reverse.find {|child| child.name == name }

          unless child
            child = Node.new name
            node << child
          end

          child
        }
      end

      private

      def normalize_property property
        property.is_a?(Enumerable) ? property.join(":") : property
      end
    end
  end
end
