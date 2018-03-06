module SqlAssess::Grader
  class OrderBy < Base
    private

    def grade
      grade_for_array
    end

    def match_score(order_by_1, order_by_2)
      if order_by_1 == order_by_2
        2
      else
        column_1 = order_by_1.split(" ")[0]
        column_2 = order_by_2.split(" ")[0]

        if column_1 == column_2
          1
        else
          0
        end
      end
    end
  end
end
