module SqlAssess::Grader
  class Base
    def self.grade_for(attribute:, student_attributes:, instructor_attributes:)
      "SqlAssess::Grader::#{attribute.capitalize}".constantize.new(
        student_attributes: student_attributes,
        instructor_attributes: instructor_attributes
      ).grade
    end
  end
end

require_relative "columns"
