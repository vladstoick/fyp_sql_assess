# frozen_string_literal: true

module SqlAssess
  module Grader
    # Grader for columns
    # @author Vlad Stoica
    class Columns < Base
      private

      def grade
        grade_for_array
      end

      def match_score(column1, column2)
        table_name1, column_name1 = column1.split('.')
        table_name2, column_name2 = column2.split('.')

        if table_name1 == table_name2
          1.0 / (levenshtein_distance(column_name1, column_name2) + 1)
        else
          0
        end
      end
    end
  end
end
