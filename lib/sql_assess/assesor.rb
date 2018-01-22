require "sql_assess/database_connection"
require "sql_assess/database_schema"
require "sql_assess/database_query_comparator"
require "sql_assess/database_query_transformer"
require "sql_assess/database_query_runner"

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
    ensure
      clear_database
    end

    def assess(create_schema_sql_query:, instructor_sql_query:, seed_sql_query:, student_sql_query:)
      create_database(create_schema_sql_query, seed_sql_query)

      result = DatabaseQueryComparator.new(@connection)
        .compare(instructor_sql_query, student_sql_query)

      result
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
