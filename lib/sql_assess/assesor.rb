require "sql_assess/database_connection"
require "sql_assess/database_schema"
require "sql_assess/database_query_comparator"
require "sql_assess/database_query_transformer"
require "sql_assess/database_query_runner"
require "sql_assess/database_data_extractor"
require "sql_assess/database_query_attribute_extractor"

module SqlAssess
  class Assesor
    def initialize(
      databse_host: "127.0.0.1",
      database_port: "3306",
      database_username: "root",
      database_name: nil
    )
      @connection = SqlAssess::DatabaseConnection.new(
        host: databse_host,
        port: database_port,
        username: database_username,
        database: database_name
      )
      clear_database
    end

    def compile(create_schema_sql_query:, instructor_sql_query:, seed_sql_query:)
      create_database(create_schema_sql_query, seed_sql_query)

      DatabaseQueryRunner.new(@connection, instructor_sql_query).run

      DatabaseDataExtractor.new(@connection).run
    ensure
      clear_database
    end

    def assess(create_schema_sql_query:, instructor_sql_query:, seed_sql_query:, student_sql_query:)
      create_database(create_schema_sql_query, seed_sql_query)

      query_result_match = DatabaseQueryComparator.new(@connection)
        .compare(instructor_sql_query, student_sql_query)

      transformer = DatabaseQueryTransformer.new(@connection)
      instructor_sql_query = transformer.transform(instructor_sql_query)
      student_sql_query = transformer.transform(student_sql_query)

      DatabaseQueryComparisonResult.new(
        success: query_result_match,
        attributes: DatabaseQueryAttributeExtractor.new(@connection).extract(
          instructor_sql_query, student_sql_query
        )
      )
    ensure
      clear_database
    end

    private

    def create_database(create_schema_sql_query, seed_sql_query)
      SqlAssess::DatabaseSchema.new(@connection).create_schema(
        create_schema_sql_query
      )

      SqlAssess::DatabaseSchema.new(@connection).seed_initial_data(
        seed_sql_query
      )
    end

    def clear_database
      SqlAssess::DatabaseSchema.new(@connection).clear_database
    end
  end
end
