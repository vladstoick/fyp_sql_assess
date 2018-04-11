# frozen_string_literal: true

require 'sql_assess/database_connection'
require 'sql_assess/runner'
require 'sql_assess/query_comparator'
require 'sql_assess/query_transformer'
require 'sql_assess/data_extractor'
require 'sql_assess/query_attribute_extractor'

module SqlAssess
  # Public interface of the library
  # @author
  class Assesor
    attr_reader :connection

    # @raise [DatabaseSchemaError] if any MySQL errors are encountered
    def initialize(database_host: '127.0.0.1', database_port: '3306', database_username: 'root', database_password: '')
      @connection = SqlAssess::DatabaseConnection.new(
        host: database_host,
        port: database_port,
        username: database_username,
        password: database_password
      )
    end

    # Compile an assignment
    # @param [String] create_schema_sql_query
    # @param [String] instructor_sql_query
    # @param [String] seed_sql_query
    # @return [Hash] see {DataExtractor#run}
    # @raise [DatabaseSeedError]
    #   if any MySQL errors are encountered while seeding the database
    # @raise [DatabaseSchemaError] if any MySQL errors are encounted
    #   while creating the schema
    # @raise [DatabaseQueryExecutionFailed] if any MySQL errors are
    #   encountered while running the instructor query
    def compile(create_schema_sql_query:, instructor_sql_query:, seed_sql_query:)
      create_database(create_schema_sql_query, seed_sql_query)

      Runner.new(@connection).execute_query(instructor_sql_query)

      QueryTransformer.new(@connection).transform(instructor_sql_query)

      DataExtractor.new(@connection).run
    ensure
      clear_database
    end

    # Assess an assignment
    # @param [String] create_schema_sql_query
    # @param [String] instructor_sql_query
    # @param [String] seed_sql_query
    # @return [QueryComparisonResult]
    # @raise [DatabaseSeedError]
    #   if any MySQL errors are encountered while seeding the database
    # @raise [DatabaseSchemaError] if any MySQL errors are encounted
    #   while creating the schema
    # @raise [DatabaseQueryExecutionFailed] if any MySQL errors are
    #   encountered while running the instructor query or student's query
    def assess(create_schema_sql_query:, instructor_sql_query:, seed_sql_query:, student_sql_query:)
      create_database(create_schema_sql_query, seed_sql_query)

      # Try to compile
      Runner.new(@connection).execute_query(student_sql_query)

      query_result_match = QueryComparator.new(@connection)
                                          .compare(instructor_sql_query, student_sql_query)

      transformer = QueryTransformer.new(@connection)
      instructor_sql_query = transformer.transform(instructor_sql_query)
      student_sql_query = transformer.transform(student_sql_query)

      attributes = QueryAttributeExtractor.new.extract(
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

    def clear_database
      @connection.delete_database
    end
  end
end
