# frozen_string_literal: true

module SqlAssess
  module Grader
    class Tables < Base
      private

      def grade
        if @instructor_attributes.length == 1 && @student_attributes.length == 1
          compare_base_grade
        else
          joins_grade = grade_for_array(
            @instructor_attributes.drop(1),
            @student_attributes.drop(1)
          )

          (joins_grade + compare_base_grade) / 2
        end
      end

      def compare_base_grade
        instructor_condition = @instructor_attributes.first
        student_condition = @student_attributes.first

        if instructor_condition == student_condition
          1
        else
          0
        end
      end

      def match_score(instructor_join, student_expressions)
        if instructor_join == student_expressions
          1
        elsif instructor_join[:table] == student_expressions[:table]
          if instructor_join[:join_type] == student_expressions[:join_type]
            0.75
          elsif instructor_join[:condition] == student_expressions[:condition]
            0.75
          else
            0.5
          end
        else
          0
        end
      end
    end
  end
end
