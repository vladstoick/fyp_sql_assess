require "spec_helper"

RSpec.describe SqlAssess::Transformers::BetweenPredicate::From do
  subject { described_class.new(connection) }

  context "when there is no having clause" do
    it "returns the same query" do
      expect(subject.transform("SELECT * FROM table")).to eq("SELECT * FROM `table`")
    end
  end

  context "when there is a having clause" do
    context "with no between query" do
      it "returns the same query" do
        expect(subject.transform("SELECT * FROM table, t3 LEFT JOIN t2 ON a = 1"))
          .to eq("SELECT * FROM `table` CROSS JOIN `t3` LEFT JOIN `t2` ON `a` = 1")
      end
    end

    context "with only a between query" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table, t3 LEFT JOIN t2 ON a BETWEEN 1 and 3"))
          .to eq("SELECT * FROM `table` CROSS JOIN `t3` LEFT JOIN `t2` ON (`a` >= 1 AND `a` <= 3)")
      end
    end

    context "with a between query and another type of query" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table LEFT JOIN t2 ON (a BETWEEN 1 and 3) AND b = 2"))
          .to eq("SELECT * FROM `table` LEFT JOIN `t2` ON ((`a` >= 1 AND `a` <= 3) AND `b` = 2)")
      end
    end

    context "with a between query and two other type of query" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table LEFT JOIN t2 ON a BETWEEN 1 and 3 AND b = 2 AND c = 3"))
          .to eq("SELECT * FROM `table` LEFT JOIN `t2` ON (((`a` >= 1 AND `a` <= 3) AND `b` = 2) AND `c` = 3)")
      end
    end
  end
end
