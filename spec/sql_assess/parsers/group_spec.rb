require "spec_helper"

RSpec.describe SqlAssess::Parsers::Group do
  subject { described_class.new(query) }

  context "with no group" do
    let(:query) { "SELECT id FROM t1 " }
    it "returns star" do
      expect(subject.group).to eq([])
    end
  end

  context "with one column in group" do
    let(:query) { "SELECT id, id2 FROM t1 GROUP BY id" }
    it "returns star" do
      expect(subject.group).to eq(["`id`"])
    end
  end

  context "with two columns in group" do
    let(:query) { "SELECT id, id2 FROM t1 GROUP BY id, id2" }
    it "returns star" do
      expect(subject.group).to eq(["`id`", "`id2`"])
    end
  end
end
