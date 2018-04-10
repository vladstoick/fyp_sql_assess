require "spec_helper"

RSpec.describe SqlAssess::Transformers::Not::From do
  subject { described_class.new(connection) }

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

  context "with join clause but no not" do
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

  context "with join clause with not" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1` LEFT JOIN `table2` ON NOT `id3` > `id1`
        GROUP BY `id1`
      SQL
    end

    it "changes the query" do
      expect(subject.transform(query)).to eq(
        <<-SQL.squish
          SELECT `table1`.`id`, `table1`.`id2`
          FROM `table1` LEFT JOIN `table2` ON `id3` <= `id1`
          GROUP BY `id1`
        SQL
      )
    end
  end

  context "with join clause with not" do
    let(:query) do
      <<-SQL.squish
        SELECT `table1`.`id`, `table1`.`id2`
        FROM `table1` LEFT JOIN `table2` ON NOT `id3` > `id1` AND NOT `id3` >= `id1`
        GROUP BY `id1`
      SQL
    end

    it "changes the query" do
      expect(subject.transform(query)).to eq(
        <<-SQL.squish
          SELECT `table1`.`id`, `table1`.`id2`
          FROM `table1` LEFT JOIN `table2` ON (`id3` <= `id1` AND `id3` < `id1`)
          GROUP BY `id1`
        SQL
      )
    end
  end
end
