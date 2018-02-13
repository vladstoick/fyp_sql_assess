require "spec_helper"

RSpec.describe SqlAssess::Parsers::Columns do
  subject { described_class.new(query) }

  context "with one column in select" do
    let(:query) { "SELECT id" }
    it "returns star" do
      expect(subject.columns).to eq(["`id`"])
    end
  end

  context "with two column in select" do
    let(:query) { "SELECT id, id2" }
    it "returns star" do
      expect(subject.columns).to eq(["`id`", "`id2`"])
    end
  end
end
