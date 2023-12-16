RSpec.describe H3 do
  include_context "constants"

  describe ".polyfill" do
    let(:geojson) do
      File.read(File.join(File.dirname(__FILE__), "support/fixtures/banbury_without_holes.json"))
    end
    let(:resolution) { 9 }
    let(:expected_count) { 14_369 }

    # NOTE: at the time of writing, flags should always be zero, but in the future it may be used
    # for results using spherical geometry: https://github.com/uber/h3/blob/master/dev-docs/RFCs/v4.0.0/polyfill-modes-rfc.md
    # https://github.com/uber/h3/blob/master/dev-docs/RFCs/v4.0.0/polyfill-modes-rfc.md
    # https://github.com/uber/h3/blob/5c91149104ac02c4f06faa4fc557e69cf6b131ef/src/h3lib/lib/algos.c#L893-L895
    subject(:polygon_to_cells) { H3.polygon_to_cells(geojson, resolution, 0) }

    it "has the correct number of hexagons" do
      expect(polygon_to_cells.count).to eq expected_count
    end

    context "when banbury area has two holes in it" do
      let(:geojson) do
        File.read(File.join(File.dirname(__FILE__), "support/fixtures/banbury.json"))
      end
      let(:expected_count) { 13_526 }

      it "has fewer hexagons" do
        expect(polygon_to_cells.count).to eq expected_count
      end
    end

    context "when polyfilling australia" do
      let(:geojson) do
        File.read(File.join(File.dirname(__FILE__), "support/fixtures/australia.json"))
      end
      let(:expect_count) { 92 }

      it "has the correct number of hexagons" do
        expect(polygon_to_cells.count).to eq expect_count
      end
    end
  end

  describe ".max_polygon_to_cells_size" do
    let(:geojson) do
      File.read(File.join(File.dirname(__FILE__), "support/fixtures/banbury.json"))
    end
    let(:resolution) { 9 }
    let(:expected_count) { 47_018 }

    # NOTE: as of 4.1.0, flags should always be zero, but in the future it may be used
    # for results using spherical geometry:
    # https://github.com/uber/h3/blob/master/dev-docs/RFCs/v4.0.0/polyfill-modes-rfc.md
    # https://github.com/uber/h3/blob/5c91149104ac02c4f06faa4fc557e69cf6b131ef/src/h3lib/lib/algos.c#L777-L779
    subject(:max_polygon_to_cells_size) { H3.max_polygon_to_cells_size(geojson, resolution, 0) }

    it "has the correct number of hexagons" do
      expect(max_polygon_to_cells_size).to eq expected_count
    end
  end

  describe ".h3_set_to_linked_geo" do
    let(:geojson) do
      File.read(File.join(File.dirname(__FILE__), "support/fixtures/banbury.json"))
    end
    let(:resolution) { 8 }
    let(:hexagons) { H3.polygon_to_cells(geojson, resolution, 0) }

    subject(:cells_to_linked_multi_polygon) { H3.cells_to_linked_multi_polygon(hexagons) }
    
    it "has 3 outlines" do
      cells_to_linked_multi_polygon.count == 3
    end

    it "can be converted to GeoJSON" do
      expect(H3.coordinates_to_geo_json(cells_to_linked_multi_polygon)).to be_truthy
    end
  end
end
