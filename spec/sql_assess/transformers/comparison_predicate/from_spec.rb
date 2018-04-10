require "spec_helper"

RSpec.describe SqlAssess::Transformers::ComparisonPredicate::From do
  subject { described_class.new(connection) }

  context "when there is no join clause" do
    it "returns the same query" do
      expect(subject.transform("SELECT * FROM table")).to eq("SELECT * FROM `table`")
    end
  end

  context "when there is a join clause" do
    context "with no comparison predicate query" do
      it "returns the same query" do
        expect(subject.transform("SELECT * FROM table LEFT JOIN t1, t3 ON a BETWEEN 1 AND 3"))
          .to eq("SELECT * FROM `table` LEFT JOIN `t1` CROSS JOIN `t3` ON `a` BETWEEN 1 AND 3")
      end
    end

    context "with a >" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table, t3 LEFT JOIN t1 ON a > 1"))
          .to eq("SELECT * FROM `table` CROSS JOIN `t3` LEFT JOIN `t1` ON 1 < `a`")
      end
    end

    context "with a > and a <" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table LEFT JOIN t1 ON a > 1 AND a < 2"))
          .to eq("SELECT * FROM `table` LEFT JOIN `t1` ON (1 < `a` AND `a` < 2)")
      end
    end

    context "with a >=" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table LEFT JOIN t1 ON a >= 1"))
          .to eq("SELECT * FROM `table` LEFT JOIN `t1` ON 1 <= `a`")
      end
    end

    context "with a <" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table LEFT JOIN t1 ON a < 1"))
          .to eq("SELECT * FROM `table` LEFT JOIN `t1` ON `a` < 1")
      end
    end

    context "with a <=" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table LEFT JOIN t1 ON a <= 1"))
          .to eq("SELECT * FROM `table` LEFT JOIN `t1` ON `a` <= 1")
      end
    end
  end
end
