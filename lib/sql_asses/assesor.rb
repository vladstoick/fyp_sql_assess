require "sql_asses/database_connection"
require "sql_asses/database_schema"

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

    def asses(create_schema_sql_query)
      create_database(create_schema_sql_query)
      clear_database
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
