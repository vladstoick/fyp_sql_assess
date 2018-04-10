# frozen_string_literal: true

require 'sql_assess/query_comparison_result'
require 'sql_assess/parsers/base'

module SqlAssess
  # Class for handling the comparison of results between two queries
  # @author Vlad Stoica
  class QueryComparator
    def initialize(connection)
      @connection = connection
    end

    # Compares the results of two queries
    #
    # @param [String] instructor_sql_query
    # @param [String] student_sql_query
    # @return [Boolean] whether the result matches
    def compare(instructor_sql_query, student_sql_query)
      instructor_result = @connection.query(instructor_sql_query).to_a
      student_result = @connection.query(student_sql_query).to_a

      success?(instructor_result, student_result)
    end

    private

    def success?(instructor_result, student_result)
      return false if instructor_result.count != student_result.count

      (0..instructor_result.count).all? do |i|
        instructor_result[i] == student_result[i]
      end
    end
  end
end
