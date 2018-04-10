# frozen_string_literal: true

module SqlAssess
  module Grader
    class OrderBy < Base
      private

      def grade
        grade_for_array
      end

      def match_score(order_by1, order_by2)
        column1, order1 = order_by1[:column].split(' ')
        column2, order2 = order_by2[:column].split(' ')
        position_difference = (order_by1[:position] - order_by2[:position]).abs + 1

        if column1 == column2
          if order1 == order2
            1.0 / position_difference
          else
            0.5 / position_difference
          end
        else
          0
        end
      end
    end
  end
end
