module SqlAssess
  class DatabaseQueryComparisonResult
    attr_reader :success,
                :student_columns, :instructor_columns

    def initialize(success:, student_columns:, instructor_columns:)
      @success = success
      @student_columns = student_columns
      @instructor_columns = instructor_columns
    end
  end
end
