require "sql_assess/grader/base"

module SqlAssess
  class QueryComparisonResult
    attr_reader :success, :attributes, :grade

    def initialize(success:, attributes:)
      @success = success
      @attributes = attributes

      if success
        @grade = 100.00
      else
        @grade = calculate_grade * 100.00
      end
    end

    private

    def calculate_grade
      grade_components_percentages.keys.sum do |key|
        SqlAssess::Grader::Base.grade_for(
          attribute: key,
          student_attributes: attributes[key]["student_#{key}".to_sym],
          instructor_attributes: attributes[key]["instructor_#{key}".to_sym]
        ) * grade_components_percentages[key]
      end
    end

    def grade_components_percentages
      {
        columns: 1 / 3.0,
        order_by: 1 / 3.0,
        where: 1 / 3.0,
      }
    end
  end
end
