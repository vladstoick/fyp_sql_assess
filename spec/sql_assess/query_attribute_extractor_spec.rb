require "spec_helper"

RSpec.describe SqlAssess::QueryAttributeExtractor do
  subject { described_class.new(connection) }

  context "columns" do
    before do
      connection.query('CREATE TABLE table1 (id integer, second integer);')
      connection.query('INSERT INTO table1 (id, second) values(1, 3);')
      connection.query('INSERT INTO table1 (id, second) values(2, 4);')
    end

    let(:instructor_query) { "SELECT id from table1" }
    let(:student_query) { "SELECT second from table1" }

    it "returns the correct format" do
      result = subject.extract(instructor_query, student_query)
      expect(result).to match({
        columns: {
          student_columns: an_instance_of(Array),
          instructor_columns: an_instance_of(Array)
        },
        order_by: {
          student_order_by: an_instance_of(Array),
          instructor_order_by: an_instance_of(Array)
        },
        where: {
          student_where: an_instance_of(Hash),
          instructor_where: an_instance_of(Hash)
        },
        tables: {
          student_tables: an_instance_of(Array),
          instructor_tables: an_instance_of(Array)
        },
        distinct_filter: {
          student_distinct_filter: an_instance_of(String),
          instructor_distinct_filter: an_instance_of(String)
        },
        limit: {
          student_limit: an_instance_of(Hash),
          instructor_limit: an_instance_of(Hash)
        },
      })
    end
  end
end
