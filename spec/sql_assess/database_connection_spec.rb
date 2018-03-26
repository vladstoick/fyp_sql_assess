require "spec_helper"

RSpec.describe SqlAssess::DatabaseConnection do
  let(:do_not_delete_database) { false }
  around do |example|
    Timecop.freeze(Time.local(1990)) do
      example.run
      subject.delete_database unless do_not_delete_database
    end
  end

  describe "#initialize" do
    context "when the user is invalid" do
      it "throws an error" do
        expect { described_class.new(username: "test") }.to raise_error(SqlAssess::DatabaseConnectionError)
      end
    end

    context "when everything is valid" do
      let(:database_url) { "valid_database" }

      it "doesn't throw an error" do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe "#database_name" do
    context "with no existing database" do
      it "uses the correct name" do
        subject
        expect(subject.query("SELECT DATABASE();").first["DATABASE()"]).to eq("000000")
      end
    end

    context "with an existing database" do
      it "creates a database with attempt in it" do
        existing_connection = described_class.new
        expect(existing_connection.query("SELECT DATABASE();").first["DATABASE()"]).to eq("000000")

        subject

        expect(subject.query("SELECT DATABASE();").first["DATABASE()"]).to eq("000000_1")

        existing_connection.delete_database
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

  describe "#delete_database" do
    context "when using default table name" do
      let(:do_not_delete_database) { true }

      it "deletes the database" do
        subject

        expect(subject.query("SELECT DATABASE();").first["DATABASE()"]).to eq("000000")

        subject.delete_database

        expect(subject.query("SHOW DATABASES;").map { |r| r["Database"] }).to_not include("000000")
      end
    end

    context "when passing default database" do
      subject { described_class.new(database: "local_db") }
      it "leaves FOREIGN_KEY_CHECKS set to ON" do
        subject.delete_database

        expect(subject.query("SHOW Variables WHERE Variable_name='foreign_key_checks';").first["Value"])
          .to eq("ON")
      end

      context "when there are no existing tables" do
        it "doesn't throw an error" do
          expect { subject.delete_database }.to_not raise_error

          tables = connection.query('SHOW tables;')

          expect(tables.count).to eq(0)
        end
      end

      context "when there are existing tables with data" do
        context "without foreign keys" do
          before do
            subject.query('CREATE TABLE table1 (id integer);')
            subject.query('CREATE TABLE table2 (id integer);')
            subject.query('INSERT INTO table1 (id) values(1);')
            subject.query('INSERT INTO table2 (id) values(1);')

            tables = subject.query("SHOW tables;")
          end

          it "drops all tables" do
            subject.delete_database

            tables = subject.query('SHOW tables;')

            expect(tables.count).to eq(0)
          end

          it "leaves FOREIGN_KEY_CHECKS set to ON" do
            subject.delete_database

            expect(subject.query("SHOW Variables WHERE Variable_name='foreign_key_checks';").first["Value"])
              .to eq("ON")
          end
        end

        context "with foreign keys" do
          before do
            subject.query('
              CREATE TABLE table1 (
                id integer,
                PRIMARY KEY (id)
              );
            ')
            subject.query('
              CREATE TABLE table2 (
                table1_id integer,
                FOREIGN KEY(table1_id) REFERENCES table1(id)
              );
            ')

            subject.query('INSERT INTO table1 (id) values(1);')
            subject.query('INSERT INTO table2 (table1_id) values(1);')

            tables = subject.query("SHOW tables;")
          end

          it "drops all tables" do
            subject.delete_database

            tables = subject.query('SHOW tables;')

            expect(tables.count).to eq(0)
          end

          it "leaves FOREIGN_KEY_CHECKS set to ON" do
            subject.delete_database

            expect(subject.query("SHOW Variables WHERE Variable_name='foreign_key_checks';").first["Value"])
              .to eq("ON")
          end
        end
      end
    end
  end
end
