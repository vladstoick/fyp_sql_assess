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
          type: "table",
          table: "`table1`",
          sql: "`table1`",
        }
      ])
    end
  end

  context "with a cross join" do
    let(:query) { "SELECT * from table1, table2" }

    it "returns an array containing the tables" do
      expect(subject.tables).to eq([
        {
          type: "table",
          table: "`table1`",
          sql: "`table1`",
        },
        {
          join_type: "CROSS JOIN",
          table: {
            type: "table",
            table: "`table2`",
            sql: "`table2`",
          },
          sql: "CROSS JOIN `table2`",
        }
      ])
    end
  end

  context "a table and a inner join" do
    let(:query) { "SELECT * FROM table1 INNER JOIN table2 ON table1.id = table2.id" }

    it "returns an array containing the tables" do
      expect(subject.tables).to eq([
        {
          type: "table",
          table: "`table1`",
          sql: "`table1`",
        },
        {
          join_type: "INNER JOIN",
          table: {
            type: "table",
            table: "`table2`",
            sql: "`table2`",
          },
          sql: "INNER JOIN `table2` ON `table1`.`id` = `table2`.`id`",
          condition: {
            type: "EQUALS",
            left: "`table1`.`id`",
            right: "`table2`.`id`",
            sql: "`table1`.`id` = `table2`.`id`"
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
          type: "table",
          table: "`table1`",
          sql: "`table1`",
        },
        {
          join_type: "LEFT JOIN",
          table: {
            type: "table",
            table: "`table2`",
            sql: "`table2`",
          },
          condition: {
            type: "EQUALS",
            left: "`table1`.`id`",
            right: "`table2`.`id`",
            sql: "`table1`.`id` = `table2`.`id`"
          },
          sql: "LEFT JOIN `table2` ON `table1`.`id` = `table2`.`id`"
        },
        {
          join_type: "LEFT JOIN",
          table: {
            type: "table",
            table: "`table3`",
            sql: "`table3`",
          },
          condition: {
            type: "EQUALS",
            left: "`table3`.`id`",
            right: "`table2`.`id`",
            sql: "`table3`.`id` = `table2`.`id`"
          },
          sql: "LEFT JOIN `table3` ON `table3`.`id` = `table2`.`id`"
        }
      ])
    end
  end

  context "a subquery" do
    let(:query) do
      <<-SQL.squish
        SELECT *
        FROM (SELECT id FROM table1)
      SQL
    end

    it "returns an array containing the tables" do
      expect(subject.tables).to eq([
        {
          type: "Subquery",
          sql: "(SELECT `id` FROM `table1`)",
          attributes: {
            columns: ["`id`"],
            order_by: [],
            where: {},
            where_tree: {},
            tables: [{type: "table", table: "`table1`", sql: "`table1`"}],
            distinct_filter: "ALL",
            limit: {limit: "inf", offset: 0},
            group: [],
            having: {},
            having_tree: {},
          }
        }
      ])
    end
  end
end
