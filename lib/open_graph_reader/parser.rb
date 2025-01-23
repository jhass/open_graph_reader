require "nokogiri"

require "open_graph_reader/parser/graph"

module OpenGraphReader
  # Parse OpenGraph tags in a HTML document into a graph.
  #
  # @api private
  class Parser
    # Some helper methods for Nokogiri
    module XPathHelpers
      # Helper to lowercase all given properties
      def self.ci_starts_with node_set, string
        node_set.select { |node|
          node.to_s.downcase.start_with? string.downcase
        }
      end
    end

    # Namespaces found in the passed documents head tag
    #
    # @return [Array<String>]
    attr_reader :additional_namespaces

    # Create a new parser.
    #
    # @param [#to_s, Nokogiri::XML::Node] html the document to parse.
    def initialize html
      @doc = to_doc html
      @additional_namespaces = []
    end

    # Whether there are any OpenGraph tags at all.
    #
    # @return [Bool]
    def any_tags?
      graph.exist?("og")
    end

    # Build and return the {Graph}.
    #
    # @return [Graph]
    def graph
      @graph ||= build_graph
    end

    # The value of the title tag of the passed document.
    #
    # @return [String]
    def title
      @doc.xpath("/html/head/title").first&.text
    end

    private

    def build_graph
      graph = Graph.new

      meta_tags.each do |tag|
        *path, leaf = tag["property"].downcase.split(":")
        node = graph.find_or_create_path path

        # @todo make stripping configurable?
        node << Graph::Node.new(leaf, tag["content"].strip)
      end

      graph
    end

    def meta_tags
      head = @doc.xpath("/html/head").first

      raise NoOpenGraphDataError, "There's no head tag in #{@doc}" unless head

      head.xpath("meta[#{xpath_condition(head)}]", XPathHelpers)
    end

    def xpath_condition head
      condition = "ci_starts_with(@property, 'og:')"

      if head["prefix"]
        @additional_namespaces = head["prefix"].scan(/(\w+):\s*([^ ]+)/)
        @additional_namespaces.map! { |prefix, _| prefix.downcase }
        @additional_namespaces.each do |additional_namespace|
          next if additional_namespace == "og"
          condition << " or ci_starts_with(@property, '#{additional_namespace}')"
        end
      end

      "(#{condition}) and @content"
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
