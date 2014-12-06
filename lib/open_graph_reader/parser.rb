require 'nokogiri'

require 'open_graph_reader/parser/graph'

module OpenGraphReader
  # Parse OpenGraph tags in a HTML document into a graph.
  #
  # @api private
  class Parser
    # Some helper methods for Nokogiri
    XPathHelpers = Class.new do
      # Helper to lowercase all given properties
      def ci_starts_with node_set, string
        node_set.select {|node|
          node.to_s.downcase.start_with? string.downcase
        }
      end
    end.new

    # Namespaces found in the passed documents head tag
    #
    # @return [Array<String>]
    attr_reader :additional_namespaces

    # Create a new parser.
    #
    # @param [#to_s, Nokogiri::XML::Node] html the document to parse.
    # @param [String] origin The source the document was obtained from.
    def initialize html, origin=nil
      @doc = to_doc html
      @origin = origin
      @additional_namespaces = []
    end

    # Whether there are any OpenGraph tags at all.
    #
    # @return [Bool]
    def has_tags?
      !graph.empty?
    end

    # Build and return the {Graph}.
    #
    # @return [Graph]
    def graph
      @graph ||= build_graph
    end

    private

    def build_graph
      graph = Graph.new
      head = @doc.xpath('/html/head').first

      raise NoOpenGraphDataError, "There's no head tag in #{@doc}" unless head

      condition = "ci_starts_with(@property, 'og:')"
      if head['prefix']
        @additional_namespaces = head['prefix'].scan(/(\w+):\s*([^ ]+)/)
        @additional_namespaces.map! {|prefix, _| prefix.downcase }
        @additional_namespaces.each do |additional_namespace|
          next if additional_namespace == 'og'
          condition << " or ci_starts_with(@property, '#{additional_namespace}')"
        end
      end

      head.xpath("meta[#{condition}]", XPathHelpers).each do |tag|
        *path, leaf = tag['property'].downcase.split(':')
        node = path.inject(graph.root) {|node, name|
          child = node.children.reverse.find {|child| child.name == name }

          unless child
            child = Graph::Node.new name
            node << child
          end

          child
        }

        # @todo make stripping configurable?
        node << Graph::Node.new(leaf, tag['content'].strip)
      end

      graph
    end

    def to_doc html
      case html
      when Nokogiri::XML::Node
        html
      else
        Nokogiri::HTML.parse(html.to_s)
      end
    end
  end
end
