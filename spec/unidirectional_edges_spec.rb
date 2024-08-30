RSpec.describe H3 do
  include_context "constants"

  describe ".neighbors?" do
    let(:origin) { "8928308280fffff".to_i(16) }
    let(:destination) { "8928308280bffff".to_i(16) }
    let(:result) { true }

    subject(:neighbors?) { H3.neighbors?(origin, destination) }

    it { is_expected.to eq(result) }

    context "when the indexes aren't neighbors" do
      let(:destination) { "89283082993ffff".to_i(16) }
      let(:result) { false }

      it { is_expected.to eq(result) }
    end
  end

  describe ".cells_to_directed_edge" do
    let(:origin) { "8928308280fffff".to_i(16) }
    let(:destination) { "8928308280bffff".to_i(16) }
    let(:result) { "16928308280fffff".to_i(16) }

    subject { H3.cells_to_directed_edge(origin, destination) }

    it { is_expected.to eq(result) }
  end

  describe ".is_directed_edge_valid?" do
    let(:edge) { "11928308280fffff".to_i(16) }
    let(:result) { true }

    subject(:h3_is_directed_edge_valid?) { H3.is_directed_edge_valid?(edge) }

    it { is_expected.to eq(result) }

    context "when the h3 index is not a valid directed edge" do
      let(:edge) { "8928308280fffff".to_i(16) }
      let(:result) { false }

      it { is_expected.to eq(result) }
    end
  end

  describe ".get_directed_edge_origin" do
    let(:edge) { "11928308280fffff".to_i(16) }
    let(:result) { "8928308280fffff".to_i(16) }

    subject(:get_directed_edge_origin) { H3.get_directed_edge_origin(edge) }

    it { is_expected.to eq(result) }
  end

  describe ".get_directed_edge_destination" do
    let(:edge) { "11928308280fffff".to_i(16) }
    let(:result) { "8928308283bffff".to_i(16) }

    subject(:get_directed_edge_destination) { H3.get_directed_edge_destination(edge) }

    it { is_expected.to eq(result) }
  end

  describe ".origin_and_destination_from_unidirectional_edge" do
    let(:h3_index) { "11928308280fffff".to_i(16) }
    let(:expected_indexes) do
      %w(8928308280fffff 8928308283bffff).map { |i| i.to_i(16) }
    end

    subject(:origin_and_destination_from_unidirectional_edge) do
      H3.origin_and_destination_from_unidirectional_edge(h3_index)
    end

    it "has two expected h3 indexes" do
      expect(origin_and_destination_from_unidirectional_edge).to eq(expected_indexes)
    end
  end

  describe ".origin_to_directed_edges" do
    subject(:origin_to_directed_edges) do
      H3.origin_to_directed_edges(h3_index)
    end

    context "when index is a hexagon" do
      let(:h3_index) { "8928308280fffff".to_i(16) }
      let(:count) { 6 }

      it "has six expected edges" do
        expect(origin_to_directed_edges.count).to eq(count)
      end
    end

    context "when index is a pentagon" do
      let(:h3_index) { "821c07fffffffff".to_i(16) }
      let(:count) { 5 }

      it "has five expected edges" do
        expect(origin_to_directed_edges.count).to eq(count)
      end
    end
  end

  describe ".unidirectional_edge_boundary" do
    let(:edge) { "11928308280fffff".to_i(16) }
    let(:expected) do
      [[37.77820687262237, -122.41971895414808], [37.77652420699321, -122.42079024541876]]
    end

    subject(:unidirectional_edge_boundary) { H3.unidirectional_edge_boundary(edge) }

    it "matches expected coordinates" do
      unidirectional_edge_boundary.zip(expected) do |(lat, lon), (exp_lat, exp_lon)|
        expect(lat).to be_within(0.000001).of(exp_lat)
        expect(lon).to be_within(0.000001).of(exp_lon)
      end
    end
  end
end
