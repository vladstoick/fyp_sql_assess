module SqlAssess::Grader
  class Where
    def initialize(student_attributes:, instructor_attributes:)
      @student_where = student_attributes
      @instructor_where = instructor_attributes
    end

    def grade
      matched_where = @student_where & @instructor_where
      matched_where.length.to_d / @instructor_where.length
    end
  end
end
