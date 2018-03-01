require "spec_helper"

RSpec.describe SqlAssess::QueryTransformer do
  let(:connection) { SqlAssess::DatabaseConnection.new }
  subject { described_class.new(connection) }

  before do
    connection.query("CREATE TABLE table1 (id1 integer, id2 integer)")
    connection.query("CREATE TABLE table2 (id3 integer, id4 integer)")
  end

  it do
    expect(subject.transform("SELECT * from table1"))
      .to eq("SELECT `table1`.`id1`, `table1`.`id2` FROM `table1`")
  end

  it do
    expect(subject.transform("SELECT * from table1 ORDER BY table1.id1 DESC"))
      .to eq("SELECT `table1`.`id1`, `table1`.`id2` FROM `table1` ORDER BY `table1`.`id1` DESC")
  end
end
