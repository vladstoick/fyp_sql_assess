# frozen_string_literal: true

module SqlAssess
  module Grader
    class Group < Base
      private

      def grade
        grade_for_array
      end

      def match_score(column1, column2)
        if column1 == column2
          2
        else
          table_name1, column_name1 = column1.split('.')
          table_name2, column_name2 = column2.split('.')

          if table_name1 == table_name2
            2.0 / levenshtein_distance(column_name1, column_name2)
          else
            0
          end
        end
      end
    end
  end
end
