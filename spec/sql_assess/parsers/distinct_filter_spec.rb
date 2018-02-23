require "spec_helper"

RSpec.describe SqlAssess::Parsers::DistinctFilter do
  subject { described_class.new(query) }

  context "with no filter in select" do
    let(:query) { "SELECT id, id2" }
    it "returns ALL" do
      expect(subject.distinct_filter).to eq("ALL")
    end
  end

  context "with ALL in select" do
    let(:query) { "SELECT ALL id, id2" }
    it "returns ALL" do
      expect(subject.distinct_filter).to eq("ALL")
    end
  end

  context "with DISTINCTROW in select" do
    let(:query) { "SELECT DISTINCTROW id, id3" }
    it "returns DISTINCTROW" do
      expect(subject.distinct_filter).to eq("DISTINCTROW")
    end
  end

  context "with DISTINCT in select" do
    let(:query) { "SELECT DISTINCT C1, c2, c3 FROM t1" }
    it "returns DISTINCT" do
      expect(subject.distinct_filter).to eq("DISTINCT")
    end
  end
end
