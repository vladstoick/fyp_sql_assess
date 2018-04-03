require "spec_helper"

RSpec.describe SqlAssess::Transformers::AmbigousColumnsOrderBy do
  subject { described_class.new(connection) }

  before do
    connection.query("CREATE TABLE table1 (id1 integer, id2 integer)")
    connection.query("CREATE TABLE table2 (id3 integer, id4 integer)")
  end

  context "with no order clause" do
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

  context "with order clause but no ambigous column" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1`
        ORDER BY `table1`.`id1` ASC
      SQL
    end

    it "doesn't change the query" do
      expect(subject.transform(query)).to eq(query)
    end
  end

  context "with order clause but with an ambigous column" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1`
        ORDER BY `id1` ASC
      SQL
    end

    it "changes the query" do
      expect(subject.transform(query)).to eq(
        <<-SQL.squish
          SELECT `table1`.`id`, `table1`.`id2`
          FROM `table1`
          ORDER BY `table1`.`id1` ASC
        SQL
      )
    end
  end

  context "with order clause but with a column number" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1`
        ORDER BY 1 ASC
      SQL
    end

    it "changes the query" do
      expect(subject.transform(query)).to eq(
        <<-SQL.squish
          SELECT `table1`.`id`, `table1`.`id2`
          FROM `table1`
          ORDER BY `table1`.`id` ASC
        SQL
      )
    end
  end
end
