require "spec_helper"

RSpec.describe SqlAssess::QueryRunner do
  let(:connection) { SqlAssess::DatabaseConnection.new }
  subject { described_class.new(connection, query) }

  before do
    connection.query('CREATE TABLE table1 (id integer);')
    connection.query('INSERT INTO table1 (id) values(1);')
    connection.query('INSERT INTO table1 (id) values(2);')
  end

  context "with a wrong query" do
    let(:query) { "SELECT id2 from table1;"}

    it "raises an exception" do
      expect { subject.run }.to raise_error(
        SqlAssess::DatabaseQueryExecutionFailed
      )
    end
  end

  context "with a correct query" do
    let(:query) { "SELECT id2 from table1;" }

    it "raises an exception" do
      expect { subject.run }.to raise_error(
        SqlAssess::DatabaseQueryExecutionFailed,
        "Unknown column 'id2' in 'field list'"
      )
    end
  end
end
