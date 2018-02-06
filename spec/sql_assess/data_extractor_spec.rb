require "spec_helper"

RSpec.describe SqlAssess::DataExtractor do
  let(:connection) { SqlAssess::DatabaseConnection.new }
  subject { described_class.new(connection) }

  context "with a single table" do
    before do
      connection.query('CREATE TABLE table1 (id integer);')
      connection.query('CREATE TABLE table2 (id integer);')
      connection.query('INSERT INTO table1 (id) values(1);')
      connection.query('INSERT INTO table1 (id) values(2);')
    end

    it "returns the correct answer" do
      expect(subject.run).to eq([
        {
          name: "table1",
          columns: [{ name: "id", type: "int(11)" }],
          data: [{ "id" => 1 }, { "id" => 2 }]
        },
        {
          name: "table2",
          columns: [{ name: "id", type: "int(11)" }],
          data: []
        },
      ])
    end
  end
end
