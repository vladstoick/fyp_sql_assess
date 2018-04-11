require "spec_helper"
require "yaml"

RSpec.describe SqlAssess::Assesor do
  before do
    allow(SqlAssess::DatabaseConnection).to receive(:new).and_return(@shared_connection)
  end

  # context "#compile" do
  #   context "without any errors" do
  #     it "returns the result from data extractor" do
  #       result = subject.compile(
  #         create_schema_sql_query: "CREATE TABLE table1 (id integer)",
  #         instructor_sql_query: "SELECT * from table1",
  #         seed_sql_query: "INSERT INTO table1 (id) VALUES (1)"
  #       )

  #       expect(result).to eq([{
  #         name: "table1",
  #         columns: [
  #           {
  #             name: "id",
  #             type: "int(11)"
  #           },
  #         ],
  #         data: [
  #           "id" => 1
  #         ],
  #       }])
  #     end
  #   end
  # end

  # context "#assess" do
  #   let(:schema_sql_query) { "CREATE TABLE table1 (id integer)" }
  #   let(:instructor_sql_query) { "SELECT * from table1" }
  #   let(:seed_sql_query) { "INSERT INTO table1 (id) VALUES (1)" }

  #   context "with a wrong student query" do
  #     let(:student_sql_query) { "SELECT * from table2" }
  #     it "raises an error and clears the database" do
  #       expect { do_assess }.to raise_error(SqlAssess::DatabaseQueryExecutionFailed)

  #       tables = subject.connection.query("SHOW tables");
  #       expect(tables.size).to eq(0)
  #     end
  #   end

  #   context "with a correct student query" do
  #     let(:student_sql_query) { "SELECT * from table1" }
  #     it "returns a result" do
  #       expect(do_assess).to be_a(SqlAssess::QueryComparisonResult)
  #     end
  #   end
  # end

  yaml = YAML.load_file("spec/fixtures/assesor_integration_tests.yml")

  yaml.each_with_index do |test, i|
    it "correctly asess integration test #{i}" do
      result = subject.assess(
        create_schema_sql_query: test["schema"],
        instructor_sql_query: test["instructor_query"],
        seed_sql_query: test["seed"],
        student_sql_query: test["student_query"]
      )
      expect(result.message).to eq(test["message"])
    end
  end

  private

  def do_assess
    subject.assess(
      create_schema_sql_query: schema_sql_query,
      instructor_sql_query: instructor_sql_query,
      seed_sql_query: seed_sql_query,
      student_sql_query: student_sql_query
    )
  end
end
