require "spec_helper"

RSpec.describe SqlAssess::Transformers::Base do
  subject { described_class.new(@connection) }

  context "#transform" do
    it "throws an error" do
      expect { subject.transform }.to raise_error('Implement this method in subclass')
    end
  end

  context "#tables" do
    context "one table" do
      let(:query) { "SELECT * from t1" }

      it "returns the table" do
        expect(subject.tables(query)).to eq(["t1"])
      end
    end

    context "two tables" do
      let(:query) { "SELECT * from t1, t2" }

      it "returns the table" do
        expect(subject.tables(query)).to eq(["t1", "t2"])
      end
    end

    context "three tables" do
      let(:query) { "SELECT * from t1, t2 LEFT JOIN t3 on t1.id = t3.id" }

      it "returns the table" do
        expect(subject.tables(query)).to eq(["t1", "t2", "t3"])
      end
    end
  end
end
