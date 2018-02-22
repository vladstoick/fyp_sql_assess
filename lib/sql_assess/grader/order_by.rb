module SqlAssess::Grader
  class OrderBy < Base
    def initialize(student_attributes:, instructor_attributes:)
      @student_order_by = student_attributes
      @instructor_order_by = instructor_attributes
    end

    def grade
      matched_order_by = @student_order_by & @instructor_order_by
      matched_order_by.length.to_d / @instructor_order_by.length
    end
  end
end
