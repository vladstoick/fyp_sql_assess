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
      expect(subject.tables).to eq([
        {
          type: "BASE",
          table: "`table1`"
        }
      ])
    end
  end

  context "with a cross join" do
    let(:query) { "SELECT * from table1, table2" }

    it "returns an array containing the tables" do
      expect(subject.tables).to eq([
        {
          type: "BASE",
          table: "`table1`"
        },
        {
          type: "CROSS JOIN",
          table: "`table2`"
        }
      ])
    end
  end

  context "a table and a inner join" do
    let(:query) { "SELECT * FROM table1 INNER JOIN table2 ON table1.id = table2.id" }

    it "returns an array containing the tables" do
      expect(subject.tables).to eq([
        {
          type: "BASE",
          table: "`table1`"
        },
        {
          type: "INNER JOIN",
          table: "`table2`",
          condition: {
            type: SqlAssess::Parsers::Where::Type::EQUALS,
            left: "`table1`.`id`",
            right: "`table2`.`id`"
          }
        }
      ])
    end
  end

  context "a table and two left join" do
    let(:query) do
      <<-SQL.squish
        SELECT *
        FROM
          table1
          LEFT JOIN table2 ON table1.id = table2.id
          LEFT JOIN table3 ON table3.id = table2.id
      SQL
    end

    it "returns an array containing the tables" do
      expect(subject.tables).to eq([
        {
          type: "BASE",
          table: "`table1`"
        },
        {
          type: "LEFT JOIN",
          table: "`table2`",
          condition: {
            type: SqlAssess::Parsers::Where::Type::EQUALS,
            left: "`table1`.`id`",
            right: "`table2`.`id`"
          }
        },
        {
          type: "LEFT JOIN",
          table: "`table3`",
          condition: {
            type: SqlAssess::Parsers::Where::Type::EQUALS,
            left: "`table3`.`id`",
            right: "`table2`.`id`"
          }
        }
      ])
    end
  end
end
