require "sql_asses/database_connection"
require "sql_asses/database_schema"
require "sql_asses/database_query_comparator"
require "sql_asses/database_query_transformer"

module SqlAsses
  class Assesor
    def initialize(
      databse_host: "127.0.0.1",
      database_port: "3306",
      database_username: "root",
      database_name: nil
    )
      @connection = SqlAsses::DatabaseConnection.new(
        host: databse_host,
        port: database_port,
        username: database_username,
        database: database_name
      )
    end

    def asses(create_schema_sql_query, instructor_sql_query, student_sql_query)
      create_database(create_schema_sql_query)

      result = DatabaseQueryComparator.new(@connection)
        .compare(instructor_sql_query, student_sql_query)

      clear_database

      result
    end

    private

    def create_database(create_schema_sql_query)
      SqlAsses::DatabaseSchema.new(@connection).create_schema(
        create_schema_sql_query
      )
    end

    def clear_database
      SqlAsses::DatabaseSchema.new(@connection).clear_database
    end
  end
end
