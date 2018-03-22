require "sql_assess/grader/base"

module SqlAssess
  class QueryComparisonResult
    attr_reader :success, :attributes, :grade, :attributes_grade

    def initialize(success:, attributes:)
      @success = success
      @attributes = attributes

      calculate_attributes_grade

      if @success == true
        @grade = 100.00
      else
        @grade = calculate_grade * 100.00
      end
    end

    private

    def calculate_grade
      attributes_grade.sum do |attribute, grade|
        grade * grade_components_percentages[attribute]
      end
    end

    def calculate_attributes_grade
      @attributes_grade ||= grade_components_percentages.keys.map do |key|
        [
          key,
          SqlAssess::Grader::Base.grade_for(
            attribute: key,
            student_attributes: attributes[key],
            instructor_attributes: attributes[key]
          ).to_d
        ]
      end.to_h
    end

    def grade_components_percentages
      {
        columns: 1 / 7.0,
        order_by: 1 / 7.0,
        where: 1 / 7.0,
        distinct_filter: 1 / 7.0,
        limit: 1 / 7.0,
        tables: 1 / 7.0,
        group: 1 / 7.0,
      }
    end
  end
end
