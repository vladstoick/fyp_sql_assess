require "spec_helper"

RSpec.describe SqlAssess::Transformers::AllColumns do
  let(:connection) { SqlAssess::DatabaseConnection.new }
  subject { described_class.new(connection) }

  before do
    connection.query("CREATE TABLE table1 (id1 integer, id2 integer)")
  end

  context "when there is no *" do
    it "returns the same query" do
      expect(subject.transform("SELECT id1 FROM table1")).to eq("SELECT `id1` FROM `table1`")
    end

    it "returns the same query" do
      expect(subject.transform("SELECT id2 FROM table1")).to eq("SELECT `id2` FROM `table1`")
    end

    it "returns the same query" do
      expect(subject.transform("SELECT id1, id2 FROM table1")).to eq("SELECT `id1`, `id2` FROM `table1`")
    end
  end

  context "when there is *" do
    it "returns the query containing all columns in select" do
      expect(subject.transform("SELECT * FROM table1")).to eq("SELECT `id1`, `id2` FROM `table1`")
    end
  end
end
