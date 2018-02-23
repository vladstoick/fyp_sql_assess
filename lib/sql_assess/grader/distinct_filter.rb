module SqlAssess::Grader
  class DistinctFilter < Base
    def initialize(student_attributes:, instructor_attributes:)
      @student_distinct = student_attributes
      @instructor_distinct = instructor_attributes
    end

    def grade
      @student_distinct == @instructor_distinct ? 1 : 0
    end
  end
end
