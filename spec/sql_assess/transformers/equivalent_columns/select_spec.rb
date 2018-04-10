require "spec_helper"

RSpec.describe SqlAssess::Transformers::EquivalentColumns::Select do
  subject { described_class.new(connection).transform(sql) }

  context "no equivalence" do
    context "with no join clause" do
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

    context "with a join clause but no equivalence" do
      let(:sql) do
        <<-SQL.squish
          SELECT `table1`.`id`
          FROM
            `table1`
            LEFT JOIN `table2` ON `table2`.`id` = `table1`.`id2`
            LEFT JOIN `table3` ON `table3`.`id` = `table1`.`id3`
        SQL
      end

      it "returns the same query" do
        expect(subject).to eq(sql)
      end
    end
  end

  context "with an equivalence" do
    context "with a left join" do
      let(:sql) do
        <<-SQL.squish
          SELECT `b`.`id`
          FROM
            `b`
            LEFT JOIN `a` ON `a`.`id` = `b`.`id`
        SQL
      end

      it "changes to the lowest string" do
        expect(subject).to eq(
          <<-SQL.squish
            SELECT `a`.`id`
            FROM
              `b`
              LEFT JOIN `a` ON `a`.`id` = `b`.`id`
          SQL
        )
      end
    end

    context "with two left joins" do
      let(:sql) do
        <<-SQL.squish
          SELECT `c`.`id`
          FROM
            `c`
            LEFT JOIN `a` ON `a`.`id` = `c`.`id`
            LEFT JOIN `b` ON `b`.`id` = `c`.`id`
        SQL
      end

      it "changes to the lowest string" do
        expect(subject).to eq(
          <<-SQL.squish
            SELECT `a`.`id`
            FROM
              `c`
              LEFT JOIN `a` ON `a`.`id` = `c`.`id`
              LEFT JOIN `b` ON `b`.`id` = `c`.`id`
          SQL
        )
      end
    end

    context "with two left joins" do
      let(:sql) do
        <<-SQL.squish
          SELECT `c`.`id`
          FROM
            `c`
            LEFT JOIN `a` ON `a`.`id` = `c`.`id`
            RIGHT JOIN `b` ON `b`.`id` = `c`.`id`
        SQL
      end

      it "changes to the lowest string" do
        expect(subject).to eq(
          <<-SQL.squish
            SELECT `a`.`id`
            FROM
              `c`
              LEFT JOIN `a` ON `a`.`id` = `c`.`id`
              RIGHT JOIN `b` ON `b`.`id` = `c`.`id`
          SQL
        )
      end
    end
  end
end
