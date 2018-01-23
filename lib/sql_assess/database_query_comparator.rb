require "sql_assess/database_query_comparison_result"
require "sql_assess/parsers/base"

module SqlAssess
  class DatabaseQueryComparator
    def initialize(connection)
      @connection = connection
    end

    def compare(instructor_sql_query, student_sql_query)
      instructor_result = @connection.query(instructor_sql_query).to_a
      student_result = @connection.query(student_sql_query).to_a

      is_success(instructor_result, student_result)
    end

    private

    def is_success(instructor_result, student_result)
      return false if instructor_result.count != student_result.count

      (0..instructor_result.count).all? do |i|
        instructor_result[i] == student_result[i]
      end
    end
  end
end
