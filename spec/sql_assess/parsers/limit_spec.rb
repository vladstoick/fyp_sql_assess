require "spec_helper"

RSpec.describe SqlAssess::Parsers::Limit do
  subject { described_class.new(query) }

  context "with no limit" do
    let(:query) { "SELECT * from table1" }
    it "returns the correct limit" do
      expect(subject.limit).to eq({
        "limit": "inf",
        "offset": 0
      })
    end
  end

  context "with limit but no offset" do
    let(:query) { "SELECT * from table1 LIMIT 1" }
    it "returns the correct limit" do
      expect(subject.limit).to eq({
        "limit": 1,
        "offset": 0
      })
    end
  end

  context "with limit and offsert" do
    let(:query) { "SELECT * from table1 LIMIT 1 OFFSET 2" }

    it "returns the correct limit" do
      expect(subject.limit).to eq({
        "limit": 1,
        "offset": 2
      })
    end
  end
end
