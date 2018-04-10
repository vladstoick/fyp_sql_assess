require "spec_helper"

RSpec.describe SqlAssess::Transformers::AmbigousColumns::Where do
  subject { described_class.new(connection) }

  before do
    connection.query("CREATE TABLE table1 (id1 integer, id2 integer)")
    connection.query("CREATE TABLE table2 (id3 integer, id4 integer)")
  end

  context "with no where clause" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1`
      SQL
    end

    it "doesn't change the query" do
      expect(subject.transform(query)).to eq(query)
    end
  end

  context "with WHERE clause but no ambigous column" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1`
        WHERE `table1`.`id1` > 1
      SQL
    end

    it "doesn't change the query" do
      expect(subject.transform(query)).to eq(query)
    end
  end

  context "with where clause but with an ambigous column" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1`
        WHERE `id1` > 1
      SQL
    end

    it "changes the query" do
      expect(subject.transform(query)).to eq(
        <<-SQL.squish
          SELECT `table1`.`id`, `table1`.`id2`
          FROM `table1`
          WHERE `table1`.`id1` > 1
        SQL
      )
    end
  end

  context "with where clause but with an ambigous column" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1`
        WHERE `id1` > 1 AND `id2` > 1
      SQL
    end

    it "changes the query" do
      expect(subject.transform(query)).to eq(
        <<-SQL.squish
          SELECT `table1`.`id`, `table1`.`id2`
          FROM `table1`
          WHERE (`table1`.`id1` > 1 AND `table1`.`id2` > 1)
        SQL
      )
    end
  end

end
