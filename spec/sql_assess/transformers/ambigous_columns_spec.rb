require "spec_helper"

RSpec.describe SqlAssess::Transformers::AmbigousColumns do
  let(:connection) { SqlAssess::DatabaseConnection.new }
  subject { described_class.new(connection) }

  before do
    connection.query("CREATE TABLE table1 (id1 integer, id2 integer)")
    connection.query("CREATE TABLE table2 (id3 integer, id4 integer)")
  end

  it "adds the table name in front of the column" do
    expect(subject.transform("SELECT id1 FROM table1"))
      .to eq("SELECT `table1.id1` FROM `table1`")
  end

  it "adds the table name in front of the column" do
    expect(subject.transform("SELECT id1, id3 FROM table1, table2"))
      .to eq("SELECT `table1.id1`, `table2.id3` FROM `table1` CROSS JOIN `table2`")
  end

  # context "for a join query" do
  #   context "when there is no *" do
  #     it "returns the same query" do
  #       expect(subject.transform("SELECT id1 FROM table1, table2")).to eq("SELECT `id1` FROM `table1` CROSS JOIN `table2`")
  #     end

  #     it "returns the same query" do
  #       expect(subject.transform("SELECT id4 FROM table1, table2")).to eq("SELECT `id4` FROM `table1` CROSS JOIN `table2`")
  #     end

  #     it "returns the same query" do
  #       expect(subject.transform("SELECT id1, id2, id3 FROM table1, table2")).to eq("SELECT `id1`, `id2`, `id3` FROM `table1` CROSS JOIN `table2`")
  #     end
  #   end

  #   context "when there is *" do
  #     it "returns the query containing all columns in select" do
  #       expect(subject.transform("SELECT * FROM table1, table2"))
  #         .to eq("SELECT `id1`, `id2`, `id3`, `id4` FROM `table1` CROSS JOIN `table2`")
  #     end
  #   end
  # end
end
