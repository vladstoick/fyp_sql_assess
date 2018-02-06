require "spec_helper"

RSpec.describe SqlAssess::QueryAttributeExtractor do
  let(:connection) { SqlAssess::DatabaseConnection.new }
  subject { described_class.new(connection) }

  context "columns" do
    before do
      connection.query('CREATE TABLE table1 (id integer, second integer);')
      connection.query('INSERT INTO table1 (id, second) values(1, 3);')
      connection.query('INSERT INTO table1 (id, second) values(2, 4);')
    end

    let(:instructor_query) { "SELECT id from table1" }
    let(:student_query) { "SELECT * from table1" }

    it "returns the correct student_columns" do
      result = subject.extract(instructor_query, student_query)
      expect(result[:columns][:instructor_columns]).to eq(["id"])
      expect(result[:columns][:student_columns]).to eq(["*"])
    end
  end
end
