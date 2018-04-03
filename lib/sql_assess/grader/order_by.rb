# frozen_string_literal: true

module SqlAssess
  module Grader
    class OrderBy < Base
      private

      def grade
        grade_for_array
      end

      def match_score(order_by1, order_by2)
        if order_by1 == order_by2
          2
        else
          column1 = order_by1.split(' ')[0]
          column2 = order_by2.split(' ')[0]

          if column1 == column2
            1
          else
            0
          end
        end
      end
    end
  end
end
