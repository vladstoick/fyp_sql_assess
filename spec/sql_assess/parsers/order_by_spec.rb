require "spec_helper"

RSpec.describe SqlAssess::Parsers::OrderBy do
  subject { described_class.new(query) }

  context "with order by one column" do
    let(:query) { "SELECT * from table1 ORDER BY id" }
    it "returns the order by clause" do
      expect(subject.order).to eq(["`id` ASC"])
    end
  end

  context "with order by multiple columns" do
    let(:query) { "SELECT * from table1 ORDER BY id, id2 DESC" }
    it "returns the order by clause" do
      expect(subject.order).to eq(["`id` ASC", "`id2` DESC"])
    end
  end

  context "with order by not present" do
    let(:query) { "SELECT * from table1" }

    it "returns empty array" do
      expect(subject.order).to eq([])
    end
  end
end
