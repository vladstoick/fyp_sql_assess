module SqlAssess
  class Runner
    def initialize(connection)
      @connection = connection
    end

    def create_schema(create_schema_sql_query)
      @connection.multiple_query(create_schema_sql_query)
    rescue Mysql2::Error => exception
      raise DatabaseSchemaError.new(exception.message)
    end

    def seed_initial_data(seed_sql_query)
      @connection.multiple_query(seed_sql_query)
    rescue Mysql2::Error => exception
      raise DatabaseSeedError.new(exception.message)
    end

    def execute_query(sql_query)
      @connection.query(sql_query)
    rescue Mysql2::Error => exception
      raise DatabaseQueryExecutionFailed.new(exception.message)
    end
  end
end
