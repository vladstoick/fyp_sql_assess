require "spec_helper"

RSpec.describe SqlAssess::Transformers::AmbigousColumns do
  subject { described_class.new(connection) }

  before do
    connection.query("CREATE TABLE table1 (id1 integer, id2 integer)")
    connection.query("CREATE TABLE table2 (id3 integer, id4 integer)")
  end

  it "adds the table name in front of the column" do
    expect(subject.transform("SELECT id1 FROM table1"))
      .to eq("SELECT `table1`.`id1` FROM `table1`")
  end

  it "leaves existing qualified columns unchanged" do
    expect(subject.transform("SELECT table1.id1 FROM table1"))
      .to eq("SELECT `table1`.`id1` FROM `table1`")
  end

  it "adds the table name in front of the column" do
    expect(subject.transform("SELECT id1, id3 FROM table1, table2"))
      .to eq("SELECT `table1`.`id1`, `table2`.`id3` FROM `table1` CROSS JOIN `table2`")
  end

end
