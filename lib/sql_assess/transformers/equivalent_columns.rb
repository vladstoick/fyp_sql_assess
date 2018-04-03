# frozen_string_literal: true

require 'rgl/adjacency'
require 'rgl/condensation.rb'

module SqlAssess
  module Transformers
    class EquivalentColumns < Base
      def transform(query)
        @parsed_query = @parser.scan_str(query)

        columns = @parsed_query.query_expression.list.columns.map do |column|
          transform_column_to_equivalent(column)
        end

        @parsed_query.query_expression.list.instance_variable_set(
          '@columns',
          columns
        )

        @parsed_query.to_sql
      end

      private

      def transform_column_to_equivalent(column)
        equivalence = equivalences_list.detect do |equivalences|
          equivalences.include?(column.to_sql)
        end

        if equivalence.present?
          table_name, column_name = equivalence.sort.first.remove('`').split('.')

          SQLParser::Statement::QualifiedColumn.new(
            SQLParser::Statement::Table.new(table_name),
            SQLParser::Statement::Column.new(column_name)
          )
        else
          column
        end
      end

      def equivalences_list
        @equivalences_list ||= build_equivalence_graph.map(&:to_a)
      end

      def build_equivalence_graph
        graph = RGL::DirectedAdjacencyGraph.new

        @equivalences = []

        join_conditions = @parsed_query.query_expression.table_expression.from_clause.tables.first
        find_equivalences(join_conditions)

        @equivalences.each do |equivalence|
          graph.add_edge(equivalence[0].to_sql, equivalence[1].to_sql)
          graph.add_edge(equivalence[1].to_sql, equivalence[0].to_sql)
        end

        graph.condensation_graph.vertices
      end

      def find_equivalences(clause)
        return unless clause.is_a?(SQLParser::Statement::LeftJoin) || clause.is_a?(SQLParser::Statement::RightJoin)

        @equivalences << [
          clause.search_condition.search_condition.left,
          clause.search_condition.search_condition.right,
        ]
        find_equivalences(clause.left)
        find_equivalences(clause.right)
      end
    end
  end
end
