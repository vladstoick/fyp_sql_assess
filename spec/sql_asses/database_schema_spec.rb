require "spec_helper"

RSpec.describe SqlAsses::DatabaseSchema do
  let(:connection) { SqlAsses::DatabaseConnection.new }
  subject { described_class.new(connection) }

  describe "#clear_database" do
    context "when there are existing tables" do
      before do
        connection.query('
          CREATE TABLE table1 (id integer);
        ')

        tables = connection.query("SHOW tables;")

        if tables.first["Tables_in_local_db"] != "table1"
          raise "Database is not cleaned"
        end
      end

      it "drops all tables" do
        subject.clear_database

        tables = connection.query('SHOW tables;')

        expect(tables.count).to eq(0)
      end
    end
  end
end
