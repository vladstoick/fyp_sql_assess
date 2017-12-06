require "sql_asses/database_query_comparison_result"

module SqlAsses
  class DatabaseQueryComparator
    def initialize(connection)
      @connection = connection
    end

    def compare(instructor_sql_query, student_sql_query)
      instructor_result = @connection.query(instructor_sql_query).to_a
      student_result = @connection.query(student_sql_query).to_a

      if instructor_result.count != student_result.count
        DatabaseQueryComparisonResult.new(
          success: false
        )
      else
        matches = (0..instructor_result.count).all? do |i|
          instructor_result[i] == student_result[i]
        end

        DatabaseQueryComparisonResult.new(
          success: matches
        )
      end
    end
  end
end
