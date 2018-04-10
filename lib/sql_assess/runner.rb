# frozen_string_literal: true

module SqlAssess
  # @author Vlad Stoica
  # A class for executing various types of queries. By providing a method
  # for each type of query, an appropiate error can be returned.
  class Runner
    def initialize(connection)
      @connection = connection
    end

    # Execute the create schema SQL query
    #
    # @param [String] create_schema_sql_query
    # @return [Hash] the results of the query
    # @raise [DatabaseSchemaError] if any MySQL errors are encountered
    def create_schema(create_schema_sql_query)
      @connection.multiple_query(create_schema_sql_query)
    rescue Mysql2::Error => exception
      raise DatabaseSchemaError, exception.message
    end

    # Execute the seed SQL query
    #
    # @param [String] seed_sql_query
    # @return [Hash] the results of the query
    # @raise [DatabaseSeedError] if any MySQL errors are encountered
    def seed_initial_data(seed_sql_query)
      @connection.multiple_query(seed_sql_query)
    rescue Mysql2::Error => exception
      raise DatabaseSeedError, exception.message
    end

    # Execute student's or instructors' query
    #
    # @param [String] sql_query
    # @return [Hash] the results of the query
    # @raise [DatabaseQueryExecutionFailed] if any MySQL errors are encountered
    def execute_query(sql_query)
      @connection.query(sql_query)
    rescue Mysql2::Error => exception
      raise DatabaseQueryExecutionFailed, exception.message
    end
  end
end
