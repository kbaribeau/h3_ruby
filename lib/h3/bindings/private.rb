module H3
  module Bindings
    # Private H3 functions which should not be called directly.
    #
    # This module provides bindings that do not have to be invoked directly by clients
    # of the library. They are used only internally to provide related public interface.
    module Private
      extend H3::Bindings::Base

      def self.safe_call(out_type, method, *in_args)
        out = FFI::MemoryPointer.new(out_type)
        send(method, *in_args + [out]).tap do |code|
          Error::raise_error(code) unless code.zero?
        end
        out.send("read_#{out_type}".to_sym)
      end

      attach_function :areNeighborCells, %i[h3_index h3_index buffer_out], :h3_error_code
      attach_function :cellToParent, [:h3_index, Resolution, H3Index], :h3_error_code
      attach_function :cell_area_km2, :cellAreaKm2, %i[h3_index buffer_out], :h3_error_code
      attach_function :cell_area_m2, :cellAreaM2, %i[h3_index buffer_out], :h3_error_code
      attach_function :cell_area_rads2, :cellAreaRads2, %i[h3_index buffer_out], :h3_error_code
      attach_function :cells_to_directed_edge, :cellsToDirectedEdge, %i[h3_index h3_index buffer_out], :h3_error_code
      attach_function :compactCells, [H3IndexesIn, H3IndexesOut, :int64], :h3_error_code
      attach_function :destroy_linked_multi_polygon, :destroyLinkedMultiPolygon, [LinkedGeoPolygon], :void
      attach_function :edge_length_km, :edgeLengthKm, %i[h3_index buffer_out], :h3_error_code
      attach_function :edge_length_m, :edgeLengthM, %i[h3_index buffer_out], :h3_error_code
      attach_function :edge_length_rads, :edgeLengthRads, %i[h3_index buffer_out], :h3_error_code
      attach_function :from_string, :stringToH3, %i[string pointer], :h3_error_code
      attach_function :geo_to_h3, :latLngToCell, [LatLng, Resolution, :pointer], :h3_error_code
      attach_function :get_haxagon_edge_length_km, :getHexagonEdgeLengthAvgKm, [Resolution, :pointer], :h3_error_code
      attach_function :get_haxagon_edge_length_m, :getHexagonEdgeLengthAvgM, [Resolution, :pointer], :h3_error_code
      attach_function :get_hexagon_area_avg_km2, :getHexagonAreaAvgKm2, [Resolution, :pointer], :h3_error_code
      attach_function :get_hexagon_area_avg_m2, :getHexagonAreaAvgM2, [Resolution, :pointer], :h3_error_code
      attach_function :get_num_cells, :getNumCells, [Resolution, :pointer], :h3_error_code
      attach_function :get_pentagons, :getPentagons, [:int, H3IndexesOut], :void
      attach_function :grid_distance, :gridDistance, %i[h3_index h3_index buffer_out], :h3_error_code
      attach_function :grid_path_cells, :gridPathCells, [:h3_index, :h3_index, H3IndexesOut], :h3_error_code
      attach_function :grid_path_cells_size, :gridPathCellsSize, %i[h3_index h3_index buffer_out], :h3_error_code
      attach_function :h3_faces, :getIcosahedronFaces, %i[h3_index buffer_out], :h3_error_code
      attach_function :get_directed_edge_origin, :getDirectedEdgeOrigin, %i[h3_index pointer], :h3_error_code
      attach_function :h3_indexes_from_unidirectional_edge, :directedEdgeToCells, [:h3_index, H3IndexesOut], :h3_error_code
      attach_function :get_directed_edge_destination, :getDirectedEdgeDestination, %i[h3_index pointer], :h3_error_code
      attach_function :h3_unidirectional_edges_from_hexagon, :originToDirectedEdges, [:h3_index, H3IndexesOut], :h3_error_code
      attach_function :cells_to_linked_multi_polygon, :cellsToLinkedMultiPolygon, [H3IndexesIn, :size_t, LinkedGeoPolygon], :h3_error_code
      attach_function :h3_to_children, :cellToChildren, [:h3_index, Resolution, H3IndexesOut], :h3_error_code
      attach_function :h3_to_geo, :cellToLatLng, [:h3_index, LatLng], :h3_error_code
      attach_function :h3_to_string, :h3ToString, %i[h3_index buffer_out size_t], :h3_error_code
      attach_function :h3_to_geo_boundary, :cellToBoundary, [:h3_index, CellBoundary], :h3_error_code
      attach_function :h3_unidirectional_edge_boundary, :directedEdgeToBoundary, [:h3_index, CellBoundary], :h3_error_code
      attach_function :grid_disk, :gridDisk, [:h3_index, :k_distance, H3IndexesOut], :h3_error_code
      attach_function :grid_disk_unsafe, :gridDiskUnsafe, [:h3_index, :k_distance, H3IndexesOut], :h3_error_code
      attach_function :grid_disks_unsafe, :gridDisksUnsafe, [H3IndexesIn, :int, :k_distance, H3IndexesOut], :h3_error_code
      attach_function :grid_disk_distances, :gridDiskDistances, [:h3_index, :int, H3IndexesOut, :buffer_out], :h3_error_code
      attach_function :grid_disk_distances_unsafe, :gridDiskDistancesUnsafe, [:h3_index, :k_distance, H3IndexesOut, :buffer_out], :h3_error_code
      attach_function :grid_ring_unsafe, :gridRingUnsafe, [:h3_index, :k_distance, H3IndexesOut], :h3_error_code
      attach_function :max_children, :cellToChildrenSize, [:h3_index, Resolution, :pointer], :h3_error_code
      attach_function :max_face_count, :maxFaceCount, %i[h3_index pointer], :h3_error_code
      attach_function :max_grid_disk_size, :maxGridDiskSize, %i[k_distance buffer_out], :h3_error_code
      attach_function :max_polygon_to_cells_size,
                      :maxPolygonToCellsSize,
                      [GeoPolygon, Resolution, :uint32, :buffer_out], # int_64
                      :h3_error_code
      attach_function :max_uncompact_size, :uncompactCellsSize, [H3IndexesIn, :int64, Resolution, :pointer], :h3_error_code
      attach_function :great_circle_distance_rads, :greatCircleDistanceRads, [LatLng, LatLng], :double
      attach_function :great_circle_distance_km, :greatCircleDistanceKm, [LatLng, LatLng], :double
      attach_function :great_circle_distance_m, :greatCircleDistanceM, [LatLng, LatLng], :double
      attach_function :polygon_to_cells, :polygonToCells, [GeoPolygon, Resolution, :uint32, H3IndexesOut], :h3_error_code
      attach_function :res_0_indexes, :getRes0Cells, [H3IndexesOut], :h3_error_code
      attach_function :uncompactCells, [H3IndexesIn, :size_t, H3IndexesOut, :size_t, Resolution], :h3_error_code
    end
  end
end
