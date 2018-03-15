require "sql_assess/grader/base"

module SqlAssess
  class QueryComparisonResult
    attr_reader :success, :attributes, :grade, :attributes_grade, :message

    def initialize(success:, attributes:)
      @success = success
      @attributes = attributes

      calculate_attributes_grade

      if @success == true
        @grade = 100.00
      else
        @grade = calculate_grade * 100.00
      end

      @message = determine_hints
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
            student_attributes: attributes[key]["student_#{key}".to_sym],
            instructor_attributes: attributes[key]["instructor_#{key}".to_sym]
          ).to_d
        ]
      end.to_h
    end

    def grade_components_percentages
      {
        tables: 1 / 7.0,
        columns: 1 / 7.0,
        group: 1 / 7.0,
        where: 1 / 7.0,
        distinct_filter: 1 / 7.0,
        limit: 1 / 7.0,
        order_by: 1 / 7.0,
      }
    end

    def determine_hints
      if success == true
        message = "Congratulations! Your solutions is correct"
      else
        message = "Your query is not correct. #{message_for_attribute(first_wrong_component)}"
      end
    end

    def first_wrong_component
      grade_components_percentages.detect do |component|
        attributes_grade[component] != 1
      end
    end

    def message_for_attribute(attribute)
      case attribute
      when :columns then "Check what columns you are selecting."
      when :tables then "Are you sure you are selecting the right tables?"
      when :order_by then "Are you ordering the rows correctly?"
      when :where then "Looks like you are selecting the right columns, but you are not selecting only the correct rows."
      when :distinct_filter then "What about duplicates? What does the exercise say?"
      when :limit then "Are you selecting the correct number of rows?"
      when :group then "Are you grouping by the correct columns?"
      end
    end
  end
end
