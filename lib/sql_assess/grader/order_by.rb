module SqlAssess::Grader
  class OrderBy < Base
    def initialize(student_attributes:, instructor_attributes:)
      @student_order_by = student_attributes
      @instructor_order_by = instructor_attributes
    end

    def grade
      max_grade = (@student_order_by.length + @instructor_order_by.length).to_d

      return 1 if max_grade == 0

      instructor_unmatched_order_bys = @instructor_order_by.dup
      student_unmatched_order_bys = @student_order_by.dup

      student_unmatched_order_bys = student_unmatched_order_bys.keep_if do |student_unmatched_order_by|
        next 0 if instructor_unmatched_order_bys.empty?

        match_score = instructor_unmatched_order_bys.map do |instructor_unmatched_order_by|
          order_by_match_score(student_unmatched_order_by, instructor_unmatched_order_by)
        end

        best_match_score = match_score.each_with_index.max

        if best_match_score[0] == 2
          instructor_unmatched_order_bys.delete_at(best_match_score[1])
          false
        else
          true
        end
      end

      matched_order_by = array_difference(@student_order_by, student_unmatched_order_bys)

      matched_grade = matched_order_by.length * 2.0

      matched_grade += student_unmatched_order_bys.sum do |student_unmatched_order_by|
        next 0 if instructor_unmatched_order_bys.empty?

        match_score = instructor_unmatched_order_bys.map do |instructor_unmatched_order_by|
          order_by_match_score(student_unmatched_order_by, instructor_unmatched_order_by)
        end

        best_match_score = match_score.each_with_index.max

        instructor_unmatched_order_bys.delete_at(best_match_score[1])

        best_match_score[0]
      end

      matched_grade / max_grade
    end

    private

    def order_by_match_score(order_by_1, order_by_2)
      if order_by_1 == order_by_2
        2
      else
        column_1, order_type_1 = order_by_1.split(" ")
        column_2, order_type_2 = order_by_2.split(" ")

        if column_1 == column_2
          1
        else
          0
        end
      end
    end
  end
end
