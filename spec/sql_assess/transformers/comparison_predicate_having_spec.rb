require "spec_helper"

RSpec.describe SqlAssess::Transformers::ComparisonPredicateHaving do
  subject { described_class.new(connection) }

  context "when there is no having clause" do
    it "returns the same query" do
      expect(subject.transform("SELECT * FROM table")).to eq("SELECT * FROM table")
    end
  end

  context "when there is a having clause" do
    context "with no comparison predicate query" do
      it "returns the same query" do
        expect(subject.transform("SELECT * FROM table HAVING a = 1"))
          .to eq("SELECT * FROM `table` HAVING `a` = 1")
      end
    end

    context "with a >" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table HAVING a > 1"))
          .to eq("SELECT * FROM `table` HAVING 1 < `a`")
      end
    end

    context "with a >=" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table HAVING a >= 1"))
          .to eq("SELECT * FROM `table` HAVING 1 <= `a`")
      end
    end

    context "with a <" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table HAVING a < 1"))
          .to eq("SELECT * FROM `table` HAVING `a` < 1")
      end
    end

    context "with a <=" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM table HAVING a <= 1"))
          .to eq("SELECT * FROM `table` HAVING `a` <= 1")
      end
    end
  end
end
