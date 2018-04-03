require "spec_helper"

RSpec.describe SqlAssess::Transformers::ComparisonPredicateWhere do
  subject { described_class.new(connection) }

  context "when there is no where clause" do
    it "returns the same query" do
      expect(subject.transform("SELECT * FROM table")).to eq("SELECT * FROM table")
    end
  end

  context "when there is a where clause" do
    context "with no comparison predicate query" do
      it "returns the same query" do
        expect(subject.transform("SELECT * FROM table WHERE a BETWEEN 1 AND 3"))
          .to eq("SELECT * FROM `table` WHERE `a` BETWEEN 1 AND 3")
      end
    end

    context "with a >" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table WHERE a > 1"))
          .to eq("SELECT * FROM `table` WHERE 1 < `a`")
      end
    end

    context "with a >=" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table WHERE a >= 1"))
          .to eq("SELECT * FROM `table` WHERE 1 <= `a`")
      end
    end

    context "with a <" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table WHERE a < 1"))
          .to eq("SELECT * FROM `table` WHERE `a` < 1")
      end
    end

    context "with a <=" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table WHERE a <= 1"))
          .to eq("SELECT * FROM `table` WHERE `a` <= 1")
      end
    end

    context "with a <= and a >" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table WHERE a <= 1 AND a > 1"))
          .to eq("SELECT * FROM `table` WHERE (`a` <= 1 AND 1 < `a`)")
      end
    end
  end
end
