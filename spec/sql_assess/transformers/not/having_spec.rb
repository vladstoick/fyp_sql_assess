require "spec_helper"

RSpec.describe SqlAssess::Transformers::Not::Having do
  subject { described_class.new(connection) }

  context "when there is no HAVING clause" do
    it "returns the same query" do
      expect(subject.transform("SELECT * FROM t1")).to eq("SELECT * FROM t1")
    end
  end

  context "when there is a HAVING clause" do
    context "with no NOT query" do
      it "returns the same query" do
        expect(subject.transform("SELECT * FROM t1 HAVING a = 1"))
          .to eq("SELECT * FROM `t1` HAVING `a` = 1")
      end
    end

    context "with only a between query" do
      context "with a > clause" do
        it "returns the updated query" do
          expect(subject.transform("SELECT * FROM t1 HAVING NOT a > 1"))
            .to eq("SELECT * FROM `t1` HAVING `a` <= 1")
        end
      end

      context "with a < clause" do
        it "returns the updated query" do
          expect(subject.transform("SELECT * FROM t1 HAVING NOT a < 1"))
            .to eq("SELECT * FROM `t1` HAVING `a` >= 1")
        end
      end

      context "with a <= clause" do
        it "returns the updated query" do
          expect(subject.transform("SELECT * FROM t1 HAVING NOT a <= 1"))
            .to eq("SELECT * FROM `t1` HAVING `a` > 1")
        end
      end

      context "with a >= clause" do
        it "returns the updated query" do
          expect(subject.transform("SELECT * FROM t1 HAVING NOT a >= 1"))
            .to eq("SELECT * FROM `t1` HAVING `a` < 1")
        end
      end
    end

    context "with a not query and another type of query" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM t1 HAVING NOT a > 1 AND b = 2"))
          .to eq("SELECT * FROM `t1` HAVING (`a` <= 1 AND `b` = 2)")
      end
    end

    context "with a not query and two other type of query" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM t1 HAVING NOT a > 1 AND b = 2 AND c = 3"))
          .to eq("SELECT * FROM `t1` HAVING ((`a` <= 1 AND `b` = 2) AND `c` = 3)")
      end
    end

    context "with a not which is not transformable" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM t1 HAVING NOT a LIKE 'a'"))
          .to eq("SELECT * FROM `t1` HAVING `a` NOT LIKE 'a'")
      end
    end
  end
end
