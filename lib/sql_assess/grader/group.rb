module SqlAssess::Grader
  class Group < Base
    private

    def grade
      grade_for_array
    end

    def match_score(column_1, column_2)
      if column_1 == column_2
        2
      else
        table_name_1, column_name_1 = column_1.split(".")
        table_name_2, column_name_2 = column_2.split(".")

        if table_name_1 == table_name_2
          2.0 / levenshtein_distance(column_name_1, column_name_2)
        else
          0
        end
      end
    end
  end
end
