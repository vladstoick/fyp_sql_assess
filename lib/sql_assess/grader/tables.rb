module SqlAssess::Grader
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
      elsif instructor_condition[:type] == "Subquery" && student_condition[:type] == "Subquery"
        match_score(instructor_condition, student_condition) / 2.0
      else
        0
      end
    end

    def match_score(instructor_condition, student_condition)
      if instructor_condition == student_condition
        2
      elsif instructor_condition[:type] == "Subquery" || student_condition[:type] == "Subquery"
        if instructor_condition[:type] == "Subquery" && student_condition[:type] == "Subquery"
          SqlAssess::QueryComparisonResult.new(
            success: false,
            attributes: {
              student: instructor_condition[:attributes],
              instructor: student_condition[:attributes]
            }
          ).grade / 50.0
        else
          0
        end
      elsif instructor_condition[:table] == student_condition[:table]
        if instructor_condition[:type] == student_condition[:type]
          1
        elsif instructor_condition[:condition] == student_condition[:condition]
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
