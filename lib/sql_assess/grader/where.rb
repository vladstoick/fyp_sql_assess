# frozen_string_literal: true

module SqlAssess
  module Grader
    class Where < Base
      def initialize(student_attributes:, instructor_attributes:)
        @student_where = student_attributes
        @instructor_where = instructor_attributes
      end

      def grade
        return 1 if @student_where == @instructor_where

        return 0 if @student_where == {} || @instructor_where == {}

        # Partial grading

        student_leaves = [get_leaves(@student_where)].flatten
        instructor_leaves = [get_leaves(@instructor_where)].flatten

        conditions_grade = grade_for_array(student_leaves, instructor_leaves)

        internal_nodes = internal_count(@student_where) + internal_count(@instructor_where)

        if internal_nodes.positive?
          tree_grade = grade_for_tree(@student_where, @instructor_where).to_d / internal_nodes
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
            child_node_grade_as_reversed,
          ].max

          current_grade + child_grade
        else
          0
        end
      end

      def internal_count(where_clause)
        if where_clause && where_clause[:is_inner]
          1 + internal_count(where_clause[:left_clause]) + internal_count(where_clause[:right_clause])
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

def get_leaves(node)
  if node.nil?
    nil
  elsif node[:is_inner] == false
    node
  else
    [
      get_leaves(node[:left_clause]),
      get_leaves(node[:right_clause]),
    ].flatten
  end
end

      def match_score(where_clause1, where_clause2)
        if where_clause1 == where_clause2
          2
        else
          0
        end
      end
    end
  end
end
