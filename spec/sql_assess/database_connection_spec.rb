require "spec_helper"

RSpec.describe SqlAssess::DatabaseConnection do
  describe "#initialize" do
    context "when the url is invalid" do
      let(:database_url) { "invalid_database" }

      it "throws an error" do
        expect { described_class.new(username: "test") }.to raise_error(SqlAssess::DatabaseConnectionError)
      end
    end

    context "when the url is valid" do
      let(:database_url) { "valid_database" }

      it "doesn't throw an error" do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe "#query" do
    it "runs the query" do
      expect(subject.query("SHOW tables").count).to eq(0)
    end
  end

  describe "#multi_query" do
    it "runs the query" do
      result = subject.multiple_query("SELECT 1; SELECT 2; SELECT 3")
      expect(result.count).to eq(3)
      expect(result.map(&:first)).to eq([{ "1" => 1 }, { "2" => 2 }, { "3" => 3 }])
    end
  end
end
