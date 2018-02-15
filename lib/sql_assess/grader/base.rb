module SqlAssess::Grader
  class Base
    def self.grade_for(attribute:, student_attributes:, instructor_attributes:)
      "SqlAssess::Grader::#{attribute.to_s.camelcase}".constantize.new(
        student_attributes: student_attributes,
        instructor_attributes: instructor_attributes
      ).grade
    end
  end
end

require_relative "columns"
require_relative "order_by"
require_relative "where"
