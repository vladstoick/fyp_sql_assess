module SqlAssess::Grader
  class Having < Base
    def initialize(student_attributes:, instructor_attributes:)
      @student_having = student_attributes
      @instructor_having = instructor_attributes
    end

    def grade
      return 1 if @student_having == @instructor_having

      return 0 if @student_having == {} || @instructor_having == {}

      # Partial grading

      student_leaves = [get_leaves(@student_having)].flatten
      instructor_leaves = [get_leaves(@instructor_having)].flatten

      conditions_grade = grade_for_array(student_leaves, instructor_leaves)

      internal_nodes = internal_count(@student_having) + internal_count(@instructor_having)

      if internal_nodes > 0
        tree_grade = grade_for_tree(@student_having, @instructor_having).to_d / internal_nodes
        (conditions_grade + tree_grade) / 2
      else
        conditions_grade
      end
    end

    private

    def grade_for_tree(student_tree, instructor_tree)
      if student_tree && student_tree[:is_inner] && instructor_tree && instructor_tree[:is_inner]
        current_grade = grade_for_node(student_tree, instructor_tree)

        child_node_grade_as_normal = grade_for_tree(student_tree[:left_clause], instructor_tree[:left_clause]) +
          grade_for_tree(student_tree[:right_clause], instructor_tree[:right_clause])

        child_node_grade_as_reversed = grade_for_tree(student_tree[:left_clause], instructor_tree[:right_clause]) +
          grade_for_tree(student_tree[:right_clause], instructor_tree[:left_clause])

        child_grade = [
          child_node_grade_as_normal,
          child_node_grade_as_reversed
        ].max

        current_grade + child_grade
      else
        0
      end
    end

    def internal_count(having_clause)
      if having_clause && having_clause[:is_inner]
        1 + internal_count(having_clause[:left_clause]) + internal_count(having_clause[:right_clause])
      else
        0
      end
    end

    def grade_for_node(student_tree, instructor_tree)
      if student_tree[:type] == instructor_tree[:type]
        2
      else
        0
      end
    end

    def get_leaves(having_clause)
      if having_clause.nil?
        nil
      elsif having_clause[:is_inner] == false
        having_clause
      else
        [
          get_leaves(having_clause[:left_clause]),
          get_leaves(having_clause[:right_clause])
        ].flatten
      end
    end

    def match_score(having_clause_1, having_clause_2)
      if having_clause_1 == having_clause_2
        2
      else
        0
      end
    end
  end
end
