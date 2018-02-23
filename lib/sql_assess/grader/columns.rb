module SqlAssess::Grader
  class Columns < Base
    def initialize(student_attributes:, instructor_attributes:)
      @student_columns = student_attributes
      @instructor_columns = instructor_attributes
    end

    def grade
      instructor_unmatched_columns = @instructor_columns.dup
      student_unmatched_columns = @student_columns.dup

      student_unmatched_columns = student_unmatched_columns.keep_if do |student_unmatched_column|
        next 0 if instructor_unmatched_columns.empty?

        match_score = instructor_unmatched_columns.map do |instructor_unmatched_column|
          column_match_score(student_unmatched_column, instructor_unmatched_column)
        end

        best_match_score = match_score.each_with_index.max

        if best_match_score[0] == 2
          instructor_unmatched_columns.delete_at(best_match_score[1])
          false
        else
          true
        end
      end

      matched_columns = array_difference(@student_columns, student_unmatched_columns)

      matched_grade = matched_columns.length * 2.0

      matched_grade += student_unmatched_columns.sum do |student_unmatched_column|
        next 0 if instructor_unmatched_columns.empty?

        match_score = instructor_unmatched_columns.map do |instructor_unmatched_column|
          column_match_score(student_unmatched_column, instructor_unmatched_column)
        end

        best_match_score = match_score.each_with_index.max

        instructor_unmatched_columns.delete_at(best_match_score[1])

        best_match_score[0]
      end

      max_grade = (@student_columns.length + @instructor_columns.length).to_d

      matched_grade / max_grade
    end

    private

    def column_match_score(column_1, column_2)
      if column_1 == column_2
        2
      else
        0
      end
    end
  end
end
