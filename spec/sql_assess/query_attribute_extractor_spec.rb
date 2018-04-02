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
        student: {
          columns: an_instance_of(Array),
          order_by: an_instance_of(Array),
          where: an_instance_of(Hash),
          where_tree: an_instance_of(Hash),
          tables: an_instance_of(Array),
          distinct_filter: an_instance_of(String),
          limit: an_instance_of(Hash),
          group: an_instance_of(Array),
          having: an_instance_of(Hash),
          having_tree: an_instance_of(Hash),
        },
        instructor: {
          columns: an_instance_of(Array),
          order_by: an_instance_of(Array),
          where: an_instance_of(Hash),
          where_tree: an_instance_of(Hash),
          tables: an_instance_of(Array),
          distinct_filter: an_instance_of(String),
          limit: an_instance_of(Hash),
          group: an_instance_of(Array),
          having: an_instance_of(Hash),
          having_tree: an_instance_of(Hash),
        },
      })
    end
  end
end
