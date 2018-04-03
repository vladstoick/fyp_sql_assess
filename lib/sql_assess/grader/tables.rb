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
        elsif instructor_condition[:type] == 'Subquery' && student_condition[:type] == 'Subquery'
          SqlAssess::QueryComparisonResult.new(
            success: false,
            attributes: {
              student: instructor_condition[:attributes],
              instructor: student_condition[:attributes],
            }
          ).grade / 100.0
        else
          0
        end
      end

      def match_score(instructor_condition, student_condition)
        if instructor_condition == student_condition
          2
        else
          if instructor_condition[:join_type] != student_condition[:join_type]
            divide = 2.0
          else
            divide = 1.0
          end

          if instructor_condition[:type] == student_condition[:type]
            if instructor_condition[:type] == 'Subquery'
              subuqery_match_score = SqlAssess::QueryComparisonResult.new(
                success: false,
                attributes: {
                  student: instructor_condition[:attributes],
                  instructor: student_condition[:attributes],
                }
              ).grade / 100.0 / 2

              subuqery_match_score / divide
            elsif instructor_condition[:table] == student_condition[:table]
              if instructor_condition[:condition] == student_condition[:condition]
                2.0 / divide
              else
                1.0 / divide
              end
            else
              0
            end
          else
            0
          end
        end
      end
    end
  end
end
