require "spec_helper"

RSpec.describe SqlAssess::Transformers::AmbigousColumns::From do
  subject { described_class.new(connection) }

  before do
    connection.query("CREATE TABLE table1 (id1 integer, id2 integer)")
    connection.query("CREATE TABLE table2 (id3 integer, id4 integer)")
  end

  context "with no join" do
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

  context "with join clause but no ambigous column" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1` LEFT JOIN `table2` ON `table2`.`id3` = `table1`.`id1`
      SQL
    end

    it "doesn't change the query" do
      expect(subject.transform(query)).to eq(query)
    end
  end

  context "with join clause but with ambigous column" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1` LEFT JOIN `table2` ON `id3` = `id1`
        GROUP BY `id1`
      SQL
    end

    it "changes the query" do
      expect(subject.transform(query)).to eq(
        <<-SQL.squish
          SELECT `table1`.`id`, `table1`.`id2`
          FROM `table1` LEFT JOIN `table2` ON `table2`.`id3` = `table1`.`id1`
          GROUP BY `id1`
        SQL
      )
    end
  end

  context "with join clause but with ambigous column" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1` LEFT JOIN `table2` ON `id3` = `id1` AND `id4` = `id2`
        GROUP BY `id1`
      SQL
    end

    it "changes the query" do
      expect(subject.transform(query)).to eq(
        <<-SQL.squish
          SELECT `table1`.`id`, `table1`.`id2`
          FROM `table1` LEFT JOIN `table2` ON (`table2`.`id3` = `table1`.`id1` AND `table2`.`id4` = `table1`.`id2`)
          GROUP BY `id1`
        SQL
      )
    end
  end
end
