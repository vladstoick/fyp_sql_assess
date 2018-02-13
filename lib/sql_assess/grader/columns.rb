module SqlAssess::Grader
  class Columns
    def initialize(student_attributes:, instructor_attributes:)
      @student_columns = student_attributes
      @instructor_columns = instructor_attributes
    end

    def grade
      matched_columns = @student_columns & @instructor_columns
      matched_columns.length.to_d / @instructor_columns.length
    end
  end
end
