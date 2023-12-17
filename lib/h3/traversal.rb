module H3
  # Grid traversal functions
  #
  # @see https://uber.github.io/h3/#/documentation/api-reference/traversal
  module Traversal
    extend H3::Bindings::Base

    # @!method max_grid_disk_size(k)
    #
    # Derive the maximum grid disk size for distance k.
    #
    # @param [Integer] k K value.
    #
    # @example Derive the maximum grid disk size for k=5
    #   H3.max_grid_disk_size(5)
    #   91
    #
    # @return [Integer] Maximum grid disk size.
    def max_grid_disk_size(k)
      Bindings::Private.safe_call(:int64, :max_grid_disk_size, k)
    end

    # @!method grid_distance(origin, h3_index)
    #
    # Derive the distance between two H3 indexes.
    #
    # @param [Integer] origin Origin H3 index
    # @param [Integer] h3_index H3 index
    #
    # @example Derive the distance between two H3 indexes.
    #   H3.grid_distance(617700169983721471, 617700169959866367)
    #   5
    #
    # @return [Integer] Distance between indexes.
    def grid_distance(origin, destination)
      Bindings::Private.safe_call(:int64, :grid_distance, origin, destination)
    end

    # @!method grid_path_cells_size(origin, destination)
    #
    # Derive the number of hexagons present in a line between two H3 indexes.
    #
    # This value is simply `h3_distance(origin, destination) + 1` when a line is computable.
    #
    # Returns a negative number if a line cannot be computed e.g.
    # a pentagon was encountered, or the hexagons are too far apart.
    #
    # @param [Integer] origin Origin H3 index
    # @param [Integer] destination H3 index
    #
    # @example Derive the number of hexagons present in a line between two H3 indexes.
    #   H3.grid_path_cells_size(617700169983721471, 617700169959866367)
    #   6
    #
    # @return [Integer] Number of hexagons found between indexes.
    def grid_path_cells_size(origin, destination)
      Bindings::Private.safe_call(:int64, :grid_path_cells_size, origin, destination)
    end

    # Derives H3 indexes within k distance of the origin H3 index.
    #
    # Similar to {grid_disk}, except that an error is raised when one of the indexes
    # returned is a pentagon or is in the pentagon distortion area.
    #
    # grid_disk-ring 0 is defined as the origin index, grid_disk 1 is defined as grid_disk 0
    # and all neighboring indexes, and so on.
    #
    # Output is inserted into the array in order of increasing distance from the origin.
    #
    # @param [Integer] origin Origin H3 index
    # @param [Integer] k K distance.
    #
    # @example Derive the grid_disk range for a given H3 index with k of 0.
    #   H3.grid_disk_unsafe(617700169983721471, 0)
    #   [617700169983721471]
    #
    # @example Derive the grid_disk range for a given H3 index with k of 1.
    #   H3.grid_disk(617700169983721471, 1)
    #   [
    #     617700169983721471, 617700170047946751, 617700169984245759,
    #     617700169982672895, 617700169983983615, 617700170044276735,
    #     617700170044014591
    #   ]
    #
    # @raise [ArgumentError] Raised if the range contains a pentagon.
    #
    # @return [Array<Integer>] Array of H3 indexes within the k-range.
    def grid_disk_unsafe(origin, k)
      max_hexagons = max_grid_disk_size(k)
      out = H3Indexes.of_size(max_hexagons)
      code = Bindings::Private.grid_disk_unsafe(origin, k, out)
      H3::Bindings::Error::raise_error(code) unless code.zero?
      out.read
    end

    # Derives H3 indexes within k distance of the origin H3 index.
    #
    # k-ring 0 is defined as the origin index, k-ring 1 is defined as k-ring 0
    # and all neighboring indexes, and so on.
    #
    # @param [Integer] origin Origin H3 index
    # @param [Integer] k K distance.
    #
    # @example Derive the k-ring for a given H3 index with k of 0.
    #   H3.k_ring(617700169983721471, 0)
    #   [617700169983721471]
    #
    # @example Derive the k-ring for a given H3 index with k of 1.
    #   H3.k_ring(617700169983721471, 1)
    #   [
    #     617700169983721471, 617700170047946751, 617700169984245759,
    #     617700169982672895, 617700169983983615, 617700170044276735,
    #     617700170044014591
    #   ]
    #
    # @return [Array<Integer>] Array of H3 indexes within the k-range.
    def grid_disk(origin, k)
      out = H3Indexes.of_size(max_grid_disk_size(k))
      Bindings::Private.grid_disk(origin, k, out).tap do |code|
        Bindings::Error::raise_error(code) unless code.zero?
      end
      out.read
    end

    # Derives the hollow hexagonal ring centered at origin with sides of length k.
    #
    # An error is raised when one of the indexes returned is a pentagon or is
    # in the pentagon distortion area.
    #
    # @param [Integer] origin Origin H3 index.
    # @param [Integer] k K distance.
    #
    # @example Derive the grid ring for the H3 index at k = 1
    #   H3.grid_ring_unsafe(617700169983721471, 1)
    #   [
    #     617700170044014591, 617700170047946751, 617700169984245759,
    #     617700169982672895, 617700169983983615, 617700170044276735
    #   ]
    #
    # @raise [ArgumentError] Raised if the grid ring contains a pentagon.
    #
    # @return [Array<Integer>] Array of H3 indexes within the grid ring.
    def grid_ring_unsafe(origin, k)
      max_hexagons = max_grid_ring_size(k)
      out = H3Indexes.of_size(max_hexagons)
      code = Bindings::Private.grid_ring_unsafe(origin, k, out)
      H3::Bindings::Error::raise_error(code) unless code.zero?
      out.read
    end

    # Derive the maximum grid ring size for a given distance k.
    #
    # NOTE: This method is not part of the H3 API and is added to this binding for convenience.
    #
    # @param [Integer] k K distance.
    #
    # @example Derive maximum grid ring size for k distance 6.
    #   H3.max_grid_ring_size(6)
    #   36
    #
    # @return [Integer] Maximum grid ring size.
    def max_grid_ring_size(k)
      k.zero? ? 1 : 6 * k
    end

    # Derives H3 indexes within k distance for each H3 index in the set.
    #
    # @param [Array<Integer>] h3_set Set of H3 indexes
    # @param [Integer] k K distance.
    # @param [Boolean] grouped Whether to group the output. Default true.
    #
    # @example Derive the hex ranges for a given H3 set with k of 0.
    #   H3.hex_ranges([617700169983721471, 617700169982672895], 1)
    #   {
    #     617700169983721471 => [
    #       [617700169983721471],
    #       [
    #         617700170047946751, 617700169984245759, 617700169982672895,
    #         617700169983983615, 617700170044276735, 617700170044014591
    #       ]
    #     ],
    #     617700169982672895 = > [
    #       [617700169982672895],
    #       [
    #         617700169984245759, 617700169983197183, 617700169983459327,
    #         617700169982935039, 617700169983983615, 617700169983721471
    #       ]
    #     ]
    #   }
    #
    # @example Derive the hex ranges for a given H3 set with k of 0 ungrouped.
    #   H3.hex_ranges([617700169983721471, 617700169982672895], 1, grouped: false)
    #   [
    #     617700169983721471, 617700170047946751, 617700169984245759,
    #     617700169982672895, 617700169983983615, 617700170044276735,
    #     617700170044014591, 617700169982672895, 617700169984245759,
    #     617700169983197183, 617700169983459327, 617700169982935039,
    #     617700169983983615, 617700169983721471
    #   ]
    #
    # @raise [ArgumentError] Raised if any of the ranges contains a pentagon.
    #
    # @see #hex_range
    #
    # @return [Hash] Hash of H3 index keys, with array values grouped by k-ring.
    def grid_disks_unsafe(h3_set, k, grouped: true)
      h3_range_indexes = grid_disks_ungrouped(h3_set, k)
      return h3_range_indexes unless grouped
      h3_range_indexes.each_slice(max_grid_disk_size(k)).each_with_object({}) do |indexes, out|
        h3_index = indexes.first

        out[h3_index] = k_rings_for_hex_range(indexes, k)
      end
    end

    # Derives the hex range for the given origin at k distance, sub-grouped by distance.
    #
    # @param [Integer] origin Origin H3 index.
    # @param [Integer] k K distance.
    #
    # @example Derive hex range at distance 2
    #   H3.grid_disk_distances_unsafe(617700169983721471, 2)
    #   {
    #     0 => [617700169983721471],
    #     1 = >[
    #       617700170047946751, 617700169984245759, 617700169982672895,
    #       617700169983983615, 617700170044276735, 617700170044014591
    #     ],
    #     2 => [
    #       617700170048995327, 617700170047684607, 617700170048471039,
    #       617700169988177919, 617700169983197183, 617700169983459327,
    #       617700169982935039, 617700175096053759, 617700175097102335,
    #       617700170043752447, 617700170043490303, 617700170045063167
    #     ]
    #   }
    #
    # @raise [ArgumentError] Raised when the hex range contains a pentagon.
    #
    # @return [Hash] Hex range grouped by distance.
    def grid_disk_distances_unsafe(origin, k)
      max_out_size = max_grid_disk_size(k)
      out = H3Indexes.of_size(max_out_size)
      distances = FFI::MemoryPointer.new(:int, max_out_size)
      code = Bindings::Private.grid_disk_distances_unsafe(origin, k, out, distances)
      H3::Bindings::Error::raise_error(code) unless code.zero?
      hexagons = out.read

      distances = distances.read_array_of_int(max_out_size)

      Hash[
        distances.zip(hexagons).group_by(&:first).map { |d, hs| [d, hs.map(&:last)] }
      ]
    end

    # Derives the k-ring for the given origin at k distance, sub-grouped by distance.
    #
    # @param [Integer] origin Origin H3 index.
    # @param [Integer] k K distance.
    #
    # @example Derive k-ring at distance 2
    #   H3.grid_disk_distances(617700169983721471, 2)
    #   {
    #     0 => [617700169983721471],
    #     1 = >[
    #       617700170047946751, 617700169984245759, 617700169982672895,
    #       617700169983983615, 617700170044276735, 617700170044014591
    #     ],
    #     2 => [
    #       617700170048995327, 617700170047684607, 617700170048471039,
    #       617700169988177919, 617700169983197183, 617700169983459327,
    #       617700169982935039, 617700175096053759, 617700175097102335,
    #       617700170043752447, 617700170043490303, 617700170045063167
    #     ]
    #   }
    #
    # @return [Hash] Hash of grid disk distances grouped by distance.
    def grid_disk_distances(origin, k)
      max_out_size = max_grid_disk_size(k)
      out = H3Indexes.of_size(max_out_size)
      distances = FFI::MemoryPointer.new(:int, max_out_size)
      Bindings::Private.grid_disk_distances(origin, k, out, distances)

      hexagons = out.read
      distances = distances.read_array_of_int(max_out_size)

      Hash[
        distances.zip(hexagons).group_by(&:first).map { |d, hs| [d, hs.map(&:last)] }
      ]
    end

    # Derives the H3 indexes found in a line between an origin H3 index
    # and a destination H3 index (inclusive of origin and destination).
    #
    # @param [Integer] origin Origin H3 index.
    # @param [Integer] destination Destination H3 index.
    #
    # @example Derive the indexes found in a line.
    #   H3.grid_path_cells(617700169983721471, 617700169959866367)
    #   [
    #     617700169983721471, 617700169984245759, 617700169988177919,
    #     617700169986867199, 617700169987391487, 617700169959866367
    #   ]
    #
    # @raise [ArgumentError] Could not compute line
    #
    # @return [Array<Integer>] H3 indexes
    def grid_path_cells(origin, destination)
      max_hexagons = grid_path_cells_size(origin, destination)
      hexagons = H3Indexes.of_size(max_hexagons)
      h3_error_code = Bindings::Private.grid_path_cells(origin, destination, hexagons)
      raise(ArgumentError, "Could not compute line, h3 error code #{h3_error_code}") unless h3_error_code.zero?
      hexagons.read
    end

    private

    def k_rings_for_hex_range(indexes, k)
      0.upto(k).map do |j|
        start  = j.zero? ? 0 : max_grid_disk_size(j - 1)
        length = max_grid_ring_size(j)
        indexes.slice(start, length)
      end
    end

    def grid_disks_ungrouped(h3_set, k)
      h3_set = H3Indexes.with_contents(h3_set)
      max_out_size = h3_set.size * max_grid_disk_size(k)
      out = H3Indexes.of_size(max_out_size)
      code = Bindings::Private.grid_disks_unsafe(h3_set, h3_set.size, k, out)
      H3::Bindings::Error::raise_error(code) unless code.zero?
      out.read
    end
  end
end
