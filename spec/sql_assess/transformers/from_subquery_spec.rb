require "spec_helper"

RSpec.describe SqlAssess::Transformers::FromSubquery do
  subject { described_class.new(connection).transform(sql) }

  before do
    connection.query("CREATE TABLE table1 (id1 integer, id2 integer)")
    connection.query("CREATE TABLE table2 (id3 integer, id4 integer)")
  end

  context "no subquery" do
    let(:sql) do
      <<-SQL.squish
        SELECT `table1`.`id`
        FROM
          `table1`
      SQL
    end

    it "returns the same query" do
      expect(subject).to eq(sql)
    end
  end


  context "with subquery" do
    let(:sql) do
      <<-SQL.squish
        SELECT `table1`.`id`
        FROM (SELECT * from table1)
      SQL
    end

    it "returns the same query" do
      expect(subject).to eq("SELECT `table1`.`id` FROM (SELECT `table1`.`id1`, `table1`.`id2` FROM `table1`)")
    end
  end
end
