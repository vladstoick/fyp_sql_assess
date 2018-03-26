require "spec_helper"

RSpec.describe SqlAssess::Runner do
  subject { described_class.new(connection) }

  describe "#create_schema" do
    context "with a correct command" do
      context "with a single command" do
        it "runs the command" do
          subject.create_schema('CREATE TABLE table1 (id integer);')

          tables = connection.query("SHOW tables");
          expect(tables.first["Tables_in_local_db"]).to eq("table1")
        end
      end

      context "with multiple commands" do
        it "runs all commands" do
          subject.create_schema('CREATE TABLE table1 (id integer); CREATE TABLE table2 (id integer);')

          tables = connection.query("SHOW tables");
          expect(tables.size).to eq(2)
          expect(tables.map{ |line| line["Tables_in_local_db"] }).to eq(["table1", "table2"])
        end
      end
    end

    context "with an incorrect command" do
      it "raises an exception" do
        expect do
          subject.create_schema('CREATE TABLES table1 (id integer);')
        end.to raise_error(
          SqlAssess::DatabaseSchemaError,
          /near .+ at line 1/
        )
      end
    end
  end

  describe "#seed_initial_data" do
    before do
      subject.create_schema('CREATE TABLE table1 (id integer);')
    end

    context "with a correct command" do
      context "with a single command" do
        it "runs the command" do
          subject.seed_initial_data('INSERT INTO table1 (id) values(1);')

          rows = connection.query('SELECT * FROM table1');
          expect(rows.count).to eq(1)
          expect(rows.first["id"]).to eq(1)
        end
      end

      context "with multiple commands" do
        it "runs all commands" do
          subject.seed_initial_data('INSERT INTO table1 (id) values(1); INSERT INTO table1 (id) values(2);')

          rows = connection.query('SELECT * FROM table1');
          expect(rows.size).to eq(2)
          expect(rows.map{ |line| line["id"] }).to eq([1, 2])
        end
      end
    end

    context "with an incorrect command" do
      it "raises an exception" do
        expect do
          subject.seed_initial_data('INSERT INTO table1 (id2) values("ab");')
        end.to raise_error(
          SqlAssess::DatabaseSeedError,
          "Unknown column 'id2' in 'field list'"
        )
      end
    end
  end

  context "#execute_query" do
    before do
      connection.query('CREATE TABLE table1 (id integer);')
      connection.query('INSERT INTO table1 (id) values(1);')
      connection.query('INSERT INTO table1 (id) values(2);')
    end

    context "with a wrong query" do
      let(:query) { "SELECT id2 from table1;" }

      it "raises an exception" do
        expect { subject.execute_query(query) }.to raise_error(
          SqlAssess::DatabaseQueryExecutionFailed
        )
      end
    end

    context "with a correct query" do
      let(:query) { "SELECT id2 from table1;" }

      it "raises an exception" do
        expect { subject.execute_query(query) }.to raise_error(
          SqlAssess::DatabaseQueryExecutionFailed,
          "Unknown column 'id2' in 'field list'"
        )
      end
    end
  end
end
