module SqlAssess::Grader
  class Where < Base
    def initialize(student_attributes:, instructor_attributes:)
      @student_where = student_attributes
      @instructor_where = instructor_attributes
    end

    def grade
      @student_where == @instructor_where ? 1 : 0
    end
  end
end
