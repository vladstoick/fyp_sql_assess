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
        send "calculate_#{key}_grade" * grade_components_percentages.fetch(key)
      end
    end

    def calculate_columns_grade
      matched_columns = attributes[:columns][:instructor_columns] & attributes[:columns][:student_columns]

      matched_columns.length.to_d / attributes[:columns][:instructor_columns].length
    end

    def grade_components_percentages
      {
        columns: 1.00
      }
    end
  end
end
