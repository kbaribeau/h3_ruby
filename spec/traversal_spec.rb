RSpec.describe H3 do
  include_context "constants"

  describe ".grid_disk" do
    let(:h3_index) { "8928308280fffff".to_i(16) }

    subject { H3.grid_disk(h3_index, k) }

    context "when k range is 1" do
      let(:k) { 1 }
      let(:count) { 7 }
      let(:expected) do
        %w(8928308280fffff 8928308280bffff 89283082873ffff 89283082877ffff
           8928308283bffff 89283082807ffff 89283082803ffff).map { |i| i.to_i(16) }
      end

      it "has 7 hexagons" do
        expect(subject.count).to eq count
      end

      it "has the expected hexagons" do
        expect(subject).to eq expected
      end
    end

    context "when k range is 2" do
      let(:k) { 2 }
      let(:count) { 19 }

      it "has 19 hexagons" do
        expect(subject.count).to eq count
      end
    end

    context "when k range is 10" do
      let(:k) { 10 }
      let(:count) { 331 }

      it "has 331 hexagons" do
        expect(subject.count).to eq count
      end
    end
  end

  describe ".max_grid_disk_size" do
    let(:k) { 2 }
    let(:result) { 19 }

    subject { H3.max_grid_disk_size(k) }

    it { is_expected.to eq(result) }

    context "when provided with a bad k value" do
      let(:k) { "boom" }

      it "raises an error" do
        expect { subject }.to raise_error(TypeError)
      end
    end

    context "when given a k too large" do
      let(:k) { too_long_number }

      it "raises an error" do
        expect { subject }.to raise_error(RangeError)
      end
    end  
  end

  describe ".grid_disk_distances" do
    let(:h3_index) { "8928308280fffff".to_i(16) }
    let(:k) { 1 }
    let(:outer_ring) do
      [
        "8928308280bffff", "89283082873ffff", "89283082877ffff",
        "8928308283bffff", "89283082807ffff", "89283082803ffff"
      ].map { |i| i.to_i(16) }
    end

    subject { H3.grid_disk_distances(h3_index, k) }

    it "has two ring sets" do
      expect(subject.count).to eq 2
    end

    it "has an inner ring containing hexagons of distance 0" do
      expect(subject[0]).to eq [h3_index]
    end

    it "has an outer ring containing hexagons of distance 1" do
      expect(subject[1].count).to eq 6
    end

    it "has an outer ring containing all expected indexes" do
      subject[1].each do |index|
        expect(outer_ring).to include(index)
      end
    end
  end

  describe ".grid_disk_unsafe" do
    let(:h3_index) { "8928308280fffff".to_i(16) }

    subject { H3.grid_disk_unsafe(h3_index, k) }

    context "when k range is 1" do
      let(:k) { 1 }
      let(:count) { 7 }
      let(:expected) do
        %w(8928308280fffff 8928308280bffff 89283082873ffff 89283082877ffff
           8928308283bffff 89283082807ffff 89283082803ffff).map { |i| i.to_i(16) }
      end

      it "has 7 hexagons" do
        expect(subject.count).to eq count
      end

      it "has the expected hexagons" do
        expect(subject).to eq expected
      end
    end

    context "when k range is 2" do
      let(:k) { 2 }
      let(:count) { 19 }

      it "has 19 hexagons" do
        expect(subject.count).to eq count
      end
    end

    context "when k range is 10" do
      let(:k) { 10 }
      let(:count) { 331 }

      it "has 331 hexagons" do
        expect(subject.count).to eq count
      end
    end

    context "when range contains a pentagon" do
      let(:h3_index) { "821c07fffffffff".to_i(16) }
      let(:k) { 1 }

      it "raises an error" do
        expect { subject }.to raise_error(H3::Bindings::Error::PentagonDistortionError)
      end
    end
  end

  describe ".grid_disk_distances_unsafe" do
    let(:h3_index) { "85283473fffffff".to_i(16) }
    let(:k) { 1 }
    let(:outer_ring) do
      [
        "85283447fffffff", "8528347bfffffff", "85283463fffffff",
        "85283477fffffff", "8528340ffffffff", "8528340bfffffff"
      ].map { |i| i.to_i(16) }
    end

    subject { H3.grid_disk_distances_unsafe(h3_index, k) }

    it "has two range sets" do
      expect(subject.count).to eq 2
    end

    it "has an inner range containing hexagons of distance 0" do
      expect(subject[0]).to eq [h3_index]
    end

    it "has an outer range containing hexagons of distance 1" do
      expect(subject[1].count).to eq 6
    end

    it "has an outer range containing all expected indexes" do
      subject[1].each do |index|
        expect(outer_ring).to include(index)
      end
    end

    context "when there is pentagonal distortion" do
      let(:h3_index) { "821c07fffffffff".to_i(16) }

      it "raises an error" do
        expect { subject }.to raise_error(H3::Bindings::Error::PentagonDistortionError)
      end
    end
  end

  describe ".grid_disks_unsafe" do
    let(:h3_index) { "8928308280fffff".to_i(16) }
    let(:h3_set) { [h3_index] }
    let(:k) { 1 }
    let(:outer_ring) do
      [
        "8928308280bffff", "89283082807ffff", "89283082877ffff",
        "89283082803ffff", "89283082873ffff", "8928308283bffff"
      ].map { |i| i.to_i(16) }
    end

    subject { H3.grid_disks_unsafe(h3_set, k) }

    it "contains a single k/v pair" do
      expect(subject.count).to eq 1
    end

    it "has one key, the h3_index" do
      expect(subject.keys.first).to eq h3_index
    end

    it "has two ring sets" do
      expect(subject[h3_index].count).to eq 2
    end

    it "has an inner ring containing only the original index" do
      expect(subject[h3_index].first).to eq [h3_index]
    end

    it "has an outer ring containing six indexes" do
      expect(subject[h3_index].last.count).to eq 6
    end

    it "has an outer ring containing all expected indexes" do
      subject[h3_index].last.each do |index|
        expect(outer_ring).to include(index)
      end
    end

    context "when there is pentagonal distortion" do
      let(:h3_index) { "821c07fffffffff".to_i(16) }

      it "raises an error" do
        expect { subject }.to raise_error(H3::Bindings::Error::PentagonDistortionError)
      end
    end

    context "when k is 2" do
      let(:k) { 2 }

      it "contains 3 rings" do
        expect(subject[h3_index].count).to eq 3
      end

      it "has an inner ring of size 1" do
        expect(subject[h3_index][0].count).to eq 1
      end

      it "has a middle ring of size 6" do
        expect(subject[h3_index][1].count).to eq 6
      end

      it "has an outer ring of size 12" do
        expect(subject[h3_index][2].count).to eq 12
      end
    end

    context "when run without grouping" do
      let(:hex_array) do
        [
          617700169958293503, 617700169958031359, 617700169964847103,
          617700169965109247, 617700169961177087, 617700169957769215,
          617700169957507071
        ]
      end

      subject { H3.grid_disks_unsafe(h3_set, k, grouped: false) }

      it { is_expected.to eq hex_array }
    end

    context "when compared with the ungrouped version" do
      let(:h3_index2) { "8f19425b6ccd582".to_i(16) }
      let(:h3_index3) { "89283082873ffff".to_i(16) }
      let(:h3_set) { [h3_index, h3_index2, h3_index3]}
      let(:ungrouped) { H3.grid_disks_unsafe(h3_set, k, grouped: false) }
      let(:k) { 3 }

      it "has the same elements when we remove grouping" do
        expect(subject.values.flatten).to eq(ungrouped)
      end
    end
  end

  describe ".grid_ring_unsafe" do
    let(:h3_index) { "8928308280fffff".to_i(16) }

    subject { H3.grid_ring_unsafe(h3_index, k) }

    context "when k range is 1" do
      let(:k) { 1 }
      let(:count) { 6 }
      let(:expected) do
        %w(89283082803ffff 8928308280bffff 89283082873ffff 89283082877ffff
           8928308283bffff 89283082807ffff).map { |i| i.to_i(16) }
      end

      it "has 6 hexagons" do
        expect(subject.count).to eq count
      end

      it "has the expected hexagons" do
        expect(subject).to eq expected
      end
    end

    context "when k range is 2" do
      let(:k) { 2 }
      let(:count) { 12 }

      it "has 12 hexagons" do
        expect(subject.count).to eq count
      end
    end

    context "when k range is 10" do
      let(:k) { 10 }
      let(:count) { 60 }

      it "has 60 hexagons" do
        expect(subject.count).to eq count
      end
    end

    context "when the ring contains a pentagon" do
      let(:h3_index) { "821c07fffffffff".to_i(16) }
      let(:k) { 1 }

      it "raises an error" do
        expect { subject }.to raise_error(H3::Bindings::Error::PentagonDistortionError)
      end
    end
  end

  describe ".distance" do
    let(:origin) { "89283082993ffff".to_i(16) }
    let(:destination) { "89283082827ffff".to_i(16) }
    let(:result) { 5 }

    subject(:grid_distance) { H3.grid_distance(origin, destination) }

    it { is_expected.to eq(result) }
  end

  describe ".grid_path_cells_size" do
    let(:origin) { "89283082993ffff".to_i(16) }
    let(:destination) { "89283082827ffff".to_i(16) }
    let(:result) { 6 }

    subject { H3.grid_path_cells_size(origin, destination) }

    it { is_expected.to eq(result) }
  end

  describe ".grid_path_cells" do
    let(:origin) { "89283082993ffff".to_i(16) }
    let(:destination) { "89283082827ffff".to_i(16) }
    let(:result) do
      [
        "89283082993ffff", "8928308299bffff", "892830829d7ffff",
        "892830829c3ffff", "892830829cbffff", "89283082827ffff"
      ].map { |i| i.to_i(16) }
    end

    subject { H3.grid_path_cells(origin, destination) }

    it { is_expected.to eq(result) }
  end
end
