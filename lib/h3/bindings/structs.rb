module H3
  module Bindings
    # FFI Structs.
    #
    # These match the structs defined in H3's header file and are required
    # to correctly interact with the library's functions.
    module Structs
      extend FFI::Library

      class LatLng < FFI::Struct
        layout :lat, :double,
               :lon, :double
      end

      class CellBoundary < FFI::Struct
        layout :num_verts, :int,
               :verts, [LatLng, 10] # array of LatLng structs (must be fixed length)
      end

      class GeoFence < FFI::Struct
        layout :num_verts, :int,
               :verts, :pointer # array of LatLng structs
      end

      class GeoPolygon < FFI::Struct
        layout :geofence, GeoFence,
               :num_holes, :int,
               :holes, :pointer # array of GeoFence structs
      end

      class GeoMultiPolygon < FFI::Struct
        layout :num_polygons, :int,
               :polygons, :pointer # array of GeoPolygon structs
      end

      class LinkedLatLng < FFI::Struct
        layout :vertex, LatLng,
               :next, LinkedLatLng.ptr
      end

      class LinkedGeoLoop < FFI::Struct
        layout :first, LinkedLatLng.ptr,
               :last, LinkedLatLng.ptr,
               :next, LinkedGeoLoop.ptr
      end

      class LinkedGeoPolygon < FFI::Struct
        layout :first, LinkedGeoLoop.ptr,
               :last, LinkedGeoLoop.ptr,
               :next, LinkedGeoPolygon.ptr
      end

      class CoordIJ < FFI::Struct
        layout :i, :int,
               :j, :int
      end
    end
  end
end
