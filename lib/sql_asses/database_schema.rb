module SqlAsses
  class DatabaseSchema
    def initialize(connection)
      @connection = connection
    end

    def create_schema(create_schema_sql_query)
      @connection.query(create_schema_sql_query)
    end

    def clear_database
      # disable foreign key checks before dropping the database
      @connection.query("SET FOREIGN_KEY_CHECKS = 0")

      tables = @connection.query("SHOW tables");

      return if tables.count.zero?

      tables.first["Tables_in_local_db"].split(",").each do |table|
        @connection.query("DROP table #{table}")
      end
    ensure
      # ensure that foreign key checks are enabled
      # at the end if any drop fails
      @connection.query("SET FOREIGN_KEY_CHECKS = 1")
    end
  end
end
