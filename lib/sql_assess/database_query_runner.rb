module SqlAssess
  class DatabaseQueryRunner
    def initialize(connection, sql_query)
      @connection = connection
      @sql_query = sql_query
    end

    def run
      @connection.query(@sql_query)
    rescue Mysql2::Error => exception
      raise DatabaseQueryExecutionFailed.new(exception.message)
    end
  end
end
