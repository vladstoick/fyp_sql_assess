require "spec_helper"

RSpec.describe SqlAssess::DatabaseQueryComparator do
  let(:connection) { SqlAssess::DatabaseConnection.new }
  subject { described_class.new(connection) }

  context "success" do
    before do
      connection.query('CREATE TABLE table1 (id integer);')
      connection.query('INSERT INTO table1 (id) values(1);')
      connection.query('INSERT INTO table1 (id) values(2);')
    end

    context "when the results are the same" do
      it "returns the right result" do
        query = "SELECT * from table1 WHERE id = 1";

        expect(subject.compare(query, query).success).to eq(true)
      end
    end

    context "when the results are different" do
      context "when the count is different" do
        it "returns the right result" do
          query = "SELECT * from table1 WHERE id = 1";
          wrong_query = "SELECT * from table1 WHERE id = 3";

          expect(subject.compare(query, wrong_query).success).to eq(false)
        end
      end

      context "when the count is the same" do
        it "returns the right result" do
          query = "SELECT * from table1 WHERE id = 1";
          wrong_query = "SELECT * from table1 WHERE id = 2";

          expect(subject.compare(query, wrong_query).success).to eq(false)
        end
      end
    end
  end

  context "columns" do
    before do
      connection.query('CREATE TABLE table1 (id integer, second integer);')
      connection.query('INSERT INTO table1 (id, second) values(1, 3);')
      connection.query('INSERT INTO table1 (id, second) values(2, 4);')
    end

    let(:instructor_query) { "SELECT id from table1" }
    let(:student_query) { "SELECT * from table1" }

    it "returns the correct student_columns" do
      result = subject.compare(instructor_query, student_query)
      expect(result.instructor_columns).to eq(["id"])
      expect(result.student_columns).to eq(["*"])
    end
  end
end
