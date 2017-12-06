require "spec_helper"

RSpec.describe SqlAsses::DatabaseConnection do
  describe "#initialize" do
    context "when the url is invalid" do
      let(:database_url) { "invalid_database" }

      it "throws an error" do
        expect { described_class.new(username: "test") }.to raise_error(SqlAsses::DatabaseConnectionError)
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
end
