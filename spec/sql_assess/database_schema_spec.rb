require "spec_helper"

RSpec.describe SqlAssess::DatabaseSchema do
  let(:connection) { SqlAssess::DatabaseConnection.new }
  subject { described_class.new(connection) }

  describe "#create_schema" do
    it "runs the command" do
      subject.create_schema('CREATE TABLE table1 (id integer);')

      tables = connection.query("SHOW tables");
      expect(tables.first["Tables_in_local_db"]).to eq("table1")
    end
  end

  describe "#clear_database" do
    context "when there are erros" do
      it "leaves FOREIGN_KEY_CHECKS set to ON" do
        allow(connection).to receive(:query).and_call_original
        allow(connection).to receive(:query).with("SHOW tables").and_raise("Error")

        expect { subject.clear_database }.to raise_error("Error")

        expect(connection.query("SHOW Variables WHERE Variable_name='foreign_key_checks';").first["Value"])
            .to eq("ON")
      end
    end

    context "when there are no errors" do
      it "leaves FOREIGN_KEY_CHECKS set to ON" do
        subject.clear_database

        expect(connection.query("SHOW Variables WHERE Variable_name='foreign_key_checks';").first["Value"])
          .to eq("ON")
      end

      context "when there are no existing tables" do
        it "doesn't throw an error" do
          expect { subject.clear_database }.to_not raise_error

          tables = connection.query('SHOW tables;')

          expect(tables.count).to eq(0)
        end
      end

      context "when there are existing tables with data" do
        context "without foreign keys" do
          before do
            connection.query('CREATE TABLE table1 (id integer);')
            connection.query('CREATE TABLE table2 (id integer);')
            connection.query('INSERT INTO table1 (id) values(1);')
            connection.query('INSERT INTO table2 (id) values(1);')

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

          it "leaves FOREIGN_KEY_CHECKS set to ON" do
            subject.clear_database

            expect(connection.query("SHOW Variables WHERE Variable_name='foreign_key_checks';").first["Value"])
              .to eq("ON")
          end
        end

        context "wit foreign keys" do
          before do
            connection.query('
              CREATE TABLE table1 (
                id integer,
                PRIMARY KEY (id)
              );
            ')
            connection.query('
              CREATE TABLE table2 (
                table1_id integer,
                FOREIGN KEY(table1_id) REFERENCES table1(id)
              );
            ')

            connection.query('INSERT INTO table1 (id) values(1);')
            connection.query('INSERT INTO table2 (table1_id) values(1);')

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

          it "leaves FOREIGN_KEY_CHECKS set to ON" do
            subject.clear_database

            expect(connection.query("SHOW Variables WHERE Variable_name='foreign_key_checks';").first["Value"])
              .to eq("ON")
          end
        end
      end
    end
  end
end
