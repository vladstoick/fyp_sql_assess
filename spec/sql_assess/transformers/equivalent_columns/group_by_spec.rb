require "spec_helper"

RSpec.describe SqlAssess::Transformers::EquivalentColumns::Group do
  subject { described_class.new(connection).transform(sql) }

  context "no equivalence" do
    context "with no join clause" do
      let(:sql) do
        <<-SQL.squish
          SELECT *
          FROM
            `table1`
          GROUP BY `table1`.`id`
        SQL
      end

      it "returns the same query" do
        expect(subject).to eq(sql)
      end
    end

    context "with a join clause but no equivalence" do
      let(:sql) do
        <<-SQL.squish
          SELECT *
          FROM
            `table1`
            LEFT JOIN `table2` ON `table2`.`id` = `table1`.`id2`
            LEFT JOIN `table3` ON `table3`.`id` = `table1`.`id3`
          GROUP BY `table1`.`id`
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
          SELECT *
          FROM
            `b`
            LEFT JOIN `a` ON `a`.`id` = `b`.`id`
          GROUP BY `b`.`id`
        SQL
      end

      it "changes to the lowest string" do
        expect(subject).to eq(
          <<-SQL.squish
            SELECT *
            FROM
              `b`
              LEFT JOIN `a` ON `a`.`id` = `b`.`id`
            GROUP BY `a`.`id`
          SQL
        )
      end
    end

    context "with two left joins" do
      let(:sql) do
        <<-SQL.squish
          SELECT *
          FROM
            `c`
            LEFT JOIN `a` ON `a`.`id` = `c`.`id`
            LEFT JOIN `b` ON `b`.`id` = `c`.`id`
          GROUP BY `c`.`id`
        SQL
      end

      it "changes to the lowest string" do
        expect(subject).to eq(
          <<-SQL.squish
            SELECT *
            FROM
              `c`
              LEFT JOIN `a` ON `a`.`id` = `c`.`id`
              LEFT JOIN `b` ON `b`.`id` = `c`.`id`
            GROUP BY `a`.`id`
          SQL
        )
      end
    end

    context "with two joins" do
      let(:sql) do
        <<-SQL.squish
          SELECT *
          FROM
            `c`
            LEFT JOIN `a` ON `a`.`id` = `c`.`id`
            RIGHT JOIN `b` ON `b`.`id` = `c`.`id`
          GROUP BY `c`.`id`
        SQL
      end

      it "changes to the lowest string" do
        expect(subject).to eq(
          <<-SQL.squish
            SELECT *
            FROM
              `c`
              LEFT JOIN `a` ON `a`.`id` = `c`.`id`
              RIGHT JOIN `b` ON `b`.`id` = `c`.`id`
            GROUP BY `a`.`id`
          SQL
        )
      end
    end
  end
end
