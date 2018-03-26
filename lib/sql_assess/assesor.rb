require "sql_assess/database_connection"
require "sql_assess/runner"
require "sql_assess/query_comparator"
require "sql_assess/query_transformer"
require "sql_assess/data_extractor"
require "sql_assess/query_attribute_extractor"

class SQLVisitorForPostgres < SQLParser::SQLVisitor
  def quote(str)
    "\"#{str}\""
  end
end


module SqlAssess
  class Assesor
    attr_reader :connection

    def initialize(databse_host: "127.0.0.1", database_port: "3306", database_username: "root")
      @connection = SqlAssess::DatabaseConnection.new(
        host: databse_host,
        port: database_port,
        username: database_username
      )
    end

    def compile(create_schema_sql_query:, instructor_sql_query:, seed_sql_query:)
      create_database(create_schema_sql_query, seed_sql_query)

      Runner.new(@connection).execute_query(instructor_sql_query)

      DataExtractor.new(@connection).run
    ensure
      clear_database
    end

    def assess(create_schema_sql_query:, instructor_sql_query:, seed_sql_query:, student_sql_query:)
      create_database(create_schema_sql_query, seed_sql_query)

      # Try to compile
      Runner.new(@connection).execute_query(student_sql_query)

      query_result_match = QueryComparator.new(@connection)
        .compare(instructor_sql_query, student_sql_query)

      transformer = QueryTransformer.new(@connection)
      instructor_sql_query = transformer.transform(instructor_sql_query)
      student_sql_query = transformer.transform(student_sql_query)

      attributes = QueryAttributeExtractor.new(@connection).extract(
        instructor_sql_query, student_sql_query
      )

      QueryComparisonResult.new(
        success: query_result_match,
        attributes: attributes
      )
    ensure
      clear_database
    end

    private

    def create_database(create_schema_sql_query, seed_sql_query)
      SqlAssess::Runner.new(@connection).create_schema(
        create_schema_sql_query
      )

      SqlAssess::Runner.new(@connection).seed_initial_data(
        seed_sql_query
      )
    end

    def clear_database(delete_databse: true)
      @connection.delete_database
    end
  end
end
