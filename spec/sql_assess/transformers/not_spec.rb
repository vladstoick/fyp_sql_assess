require "spec_helper"

RSpec.describe SqlAssess::Transformers::Not do
  subject { described_class.new(SqlAssess::DatabaseConnection.new) }

  context "when there is no where clause" do
    it "returns the same query" do
      expect(subject.transform("SELECT * FROM t1")).to eq("SELECT * FROM `t1`")
    end
  end

  context "when there is a where clause" do
    context "with no NOT query" do
      it "returns the same query" do
        expect(subject.transform("SELECT * FROM t1 WHERE a = 1"))
          .to eq("SELECT * FROM `t1` WHERE `a` = 1")
      end
    end

    context "with only a between query" do
      context "with a > clause" do
        it "returns the updated query" do
          expect(subject.transform("SELECT * FROM t1 WHERE NOT a > 1"))
            .to eq("SELECT * FROM `t1` WHERE `a` <= 1")
        end
      end

      context "with a < clause" do
        it "returns the updated query" do
          expect(subject.transform("SELECT * FROM t1 WHERE NOT a < 1"))
            .to eq("SELECT * FROM `t1` WHERE `a` >= 1")
        end
      end

      context "with a <= clause" do
        it "returns the updated query" do
          expect(subject.transform("SELECT * FROM t1 WHERE NOT a <= 1"))
            .to eq("SELECT * FROM `t1` WHERE `a` > 1")
        end
      end

      context "with a >= clause" do
        it "returns the updated query" do
          expect(subject.transform("SELECT * FROM t1 WHERE NOT a >= 1"))
            .to eq("SELECT * FROM `t1` WHERE `a` < 1")
        end
      end
    end

    context "with a not query and another type of query" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM t1 WHERE NOT a > 1 AND b = 2"))
          .to eq("SELECT * FROM `t1` WHERE (`a` <= 1 AND `b` = 2)")
      end
    end

    context "with a not query and two other type of query" do
      it "returns the updated query" do
        expect(subject.transform("SELECT * FROM t1 WHERE NOT a > 1 AND b = 2 AND c = 3"))
          .to eq("SELECT * FROM `t1` WHERE ((`a` <= 1 AND `b` = 2) AND `c` = 3)")
      end
    end
  end
end
