# frozen_string_literal: true

module SqlAssess
  module Parsers
    # @author Vlad Stoica
    # Parser for the WHERE clause
    class Where < Base
      # @return [Hash] the binary expression tree of the WHERE clause
      def where
        if @parsed_query.query_expression.table_expression.where_clause.nil?
          {}
        else
          self.class.transform(@parsed_query.query_expression.table_expression.where_clause.search_condition)
        end
      end

      # @return [Hash] the expression tree (not binary tree) of the WHERE clause
      def where_tree
        if @parsed_query.query_expression.table_expression.where_clause.nil?
          {}
        else
          transform_tree(
            @parsed_query.query_expression.table_expression.where_clause.search_condition
          )
        end
      end

      # Transform a clause to a tree
      # @param [SQLParser::Statement] clause current node
      # @return [Hash] tree version the clause
      def self.transform(clause)
        if clause.is_a?(SQLParser::Statement::ComparisonPredicate)
          {
            type: clause.class.name.split('::').last.underscore.humanize.upcase,
            left: clause.left.to_sql,
            right: clause.right.to_sql,
            sql: clause.to_sql,
          }
        elsif clause.is_a?(SQLParser::Statement::SearchCondition)
          type = clause.class.name.split('::').last.underscore.humanize.upcase
          transform_left = merge(type, transform(clause.left))
          transform_right = merge(type, transform(clause.right))
          {
            type: type,
            clauses: [
              transform_left,
              transform_right,
            ].flatten,
          }
        end
      end

      def self.merge(type, clause)
        if clause[:type] == type
          clause[:clauses]
        else
          clause
        end
      end
      private_class_method :merge

      private

      def transform_tree(clause)
        if clause.is_a?(SQLParser::Statement::ComparisonPredicate)
          {
            is_inner: false,
            type: clause.class.name.split('::').last.underscore.humanize.upcase,
            left: clause.left.to_sql,
            right: clause.right.to_sql,
            sql: clause.to_sql,
          }
        elsif clause.is_a?(SQLParser::Statement::SearchCondition)
          type = clause.class.name.split('::').last.underscore.humanize.upcase

          {
            is_inner: true,
            type: type,
            left_clause: transform_tree(clause.left),
            right_clause: transform_tree(clause.right),
          }
        end
      end
    end
  end
end
