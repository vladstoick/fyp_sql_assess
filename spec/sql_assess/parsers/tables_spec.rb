require "spec_helper"

RSpec.describe SqlAssess::Parsers::Tables do
  subject { described_class.new(query) }

  context "with no table" do
    let(:query) { "SELECT 1" }

    it "returns an empty array" do
      expect(subject.tables).to eq([])
    end
  end

  context "with one table" do
    let(:query) { "SELECT * from table1" }
    it "returns an array containing the tables" do
      expect(subject.tables).to eq(["`table1`"])
    end
  end

  context "with a cross join" do
    let(:query) { "SELECT * from table1, table2" }

    it "returns an array containing the tables" do
      expect(subject.tables).to eq(["`table1`", "CROSS JOIN `table2`"])
    end
  end

  context "a table and a inner join" do
    let(:query) { "SELECT * FROM table1 INNER JOIN table2 ON table1.id = table2.id" }

    it "returns an array containing the tables" do
      expect(subject.tables).to eq(["`table1`", "INNER JOIN `table2`"])
    end
  end
end
