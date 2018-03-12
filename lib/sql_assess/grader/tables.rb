module SqlAssess::Grader
  class Tables < Base
    private

    def grade
      compare_base_grade = @student_attributes[0] == @instructor_attributes[0] ? 1 : 0

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

    def match_score(condition_1, condition_2)
      if condition_1 == condition_2
        2
      elsif condition_1[:table] == condition_2[:table]
        if condition_1[:type] == condition_2[:type]
          1
        elsif condition_1[:condition] == condition_2[:condition]
          1
        else
          # or look at differences in type or condition
          0.5
        end
      else
        0
      end
    end
  end
end
