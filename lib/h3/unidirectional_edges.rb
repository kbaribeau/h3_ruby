module H3
  # Unidirectional edge functions
  #
  # @see https://uber.github.io/h3/#/documentation/api-reference/unidirectional-edges
  module UnidirectionalEdges
    extend H3::Bindings::Base

    # @!method neighbors?(origin, destination)
    #
    # Determine whether two H3 indexes are neighbors.
    #
    # @param [Integer] origin Origin H3 index
    # @param [Integer] destination Destination H3 index
    #
    # @example Check two H3 indexes
    #   H3.neighbors?(617700169958293503, 617700169958031359)
    #   true
    #
    # @return [Boolean] True if indexes are neighbors
    attach_predicate_function :neighbors?, :areNeighborCells, %i[h3_index h3_index], :bool
    def neighbors?(h3_index, h3_index2)
      Bindings::Private.safe_call(:int64, :areNeighborCells, h3_index, h3_index2) > 0
    end

    # @!method is_directed_edge_valid?(h3_index)
    #
    # Determine whether the given H3 index represents a directed edge.
    #
    # @param [Integer] h3_index H3 index
    #
    # @example Check if H3 index is a valid directed edge.
    #   H3.is_directed_edge_valid?(1266218516299644927)
    #   true
    #
    # @return [Boolean] True if H3 index is a valid directed edge
    attach_predicate_function :is_directed_edge_valid?,
                              :isValidDirectedEdge,
                              %i[h3_index],
                              :bool

    # @!method cells_to_directed_edge(origin, destination)
    #
    # Derives the H3 index of the edge from the given H3 indexes.
    #
    # @param [Integer] origin H3 index
    # @param [Integer] destination H3 index
    #
    # @example Derive the H3 edge index between two H3 indexes
    #   H3.cells_to_directed_edge(617700169958293503, 617700169958031359)
    #   1626506486489284607
    #
    # @return [Integer] H3 edge index
    def cells_to_directed_edge(origin, destination)
      Bindings::Private.safe_call(:ulong_long, :cells_to_directed_edge, origin, destination)
    end

    # @!method get_directed_edge_destination(edge)
    #
    # Derive destination H3 index from edge.
    #
    # @param [Integer] edge H3 edge index
    #
    # @example Get destination index from edge
    #   H3.get_directed_edge_destination(1266218516299644927)
    #   617700169961177087
    #
    # @return [Integer] H3 index
    def get_directed_edge_destination(h3_index)
      Bindings::Private.safe_call(:ulong_long, :get_directed_edge_destination, h3_index)
    end

    # @!method get_directed_edge_origin(edge)
    #
    # Derive origin H3 index from edge.
    #
    # @param [Integer] edge H3 edge index
    #
    # @example Get origin index from edge
    #   H3.get_directed_edge_origin(1266218516299644927)
    #   617700169958293503
    #
    # @return [Integer] H3 index
    def get_directed_edge_origin(h3_index)
      Bindings::Private.safe_call(:ulong_long, :get_directed_edge_origin, h3_index)
    end

    # Derive origin and destination H3 indexes from edge.
    #
    # Returned in the form
    #
    #   [origin, destination]
    #
    # @param [Integer] edge H3 edge index
    #
    # @example Get origin and destination indexes from edge
    #   H3.origin_and_destination_from_unidirectional_edge(1266218516299644927)
    #   [617700169958293503, 617700169961177087]
    #
    # @return [Array<Integer>] H3 index array.
    def origin_and_destination_from_unidirectional_edge(edge)
      max_hexagons = 2
      out = H3Indexes.of_size(max_hexagons)
      Bindings::Private.h3_indexes_from_unidirectional_edge(edge, out)
      out.read
    end

    # Derive directed edges for a H3 index.
    #
    # @param [Integer] origin H3 index
    #
    # @example Get directed edge indexes from hexagon
    #   H3.origin_to_directed_edges(612933930963697663)
    #   [
    #     1261452277305049087, 1333509871342977023, 1405567465380904959,
    #     1477625059418832895, 1549682653456760831, 1621740247494688767
    #   ]
    #
    # @return [Array<Integer>] H3 index array.
    def origin_to_directed_edges(origin)
      max_edges = 6
      out = H3Indexes.of_size(max_edges)
      Bindings::Private.h3_origin_to_directed_edges(origin, out)
      out.read
    end

    # Derive coordinates for edge boundary.
    #
    # @param [Integer] edge H3 edge index
    #
    # @example
    #   H3.directed_edge_boundary(612933930963697663)
    #   [
    #     [68.92995788193981, 31.831280499087402], [69.39359648991828, 62.345344956509784],
    #     [76.163042830191, 94.14309010184775], [87.36469532319619, 145.5581976913368],
    #     [81.27137179020497, -34.75841798028461], [73.31022368544393, 0.32561035194326043]
    #   ]
    #
    # @return [Array<Array<Float>>] Edge boundary coordinates for a hexagon
    def directed_edge_boundary(edge)
      geo_boundary = CellBoundary.new
      Bindings::Private.h3_directed_edge_boundary(edge, geo_boundary)
      geo_boundary[:verts].take(geo_boundary[:num_verts]).map do |d|
        [rads_to_degs(d[:lat]), rads_to_degs(d[:lon])]
      end
    end
  end
end
