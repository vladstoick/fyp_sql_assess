# frozen_string_literal: true

require 'rgl/adjacency'
require 'rgl/condensation.rb'

module SqlAssess
  module Transformers
    # Transformers for equivalent columns
    module EquivalentColumns
      # @author Vlad Stoica
      # Base class for transformers for equivalent column
      class Base < SqlAssess::Transformers::Base
        # The list of equivalent columns transformers
        def self.transformers
          [Select, Where, Group, OrderBy, Having]
        end

        private

        def transform_column(column)
          if column.is_a?(SQLParser::Statement::QualifiedColumn)
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
          elsif column.is_a?(SQLParser::Statement::Aggregate)
            column.class.new(transform_column(column.column))
          elsif column.is_a?(SQLParser::Statement::Arithmetic) || column.is_a?(SQLParser::Statement::ComparisonPredicate)
            column.class.new(
              transform_column(column.left),
              transform_column(column.right)
            )
          else
            column
          end
        end

        def transform_tree(node)
          if node.is_a?(SQLParser::Statement::SearchCondition)
            node.class.new(
              transform_tree(node.left),
              transform_tree(node.right)
            )
          else
            transform_column(node)
          end
        end

        def equivalences_list
          @equivalences_list ||= build_equivalence_graph.map(&:to_a)
        end

        def build_equivalence_graph
          graph = RGL::DirectedAdjacencyGraph.new

          join_conditions = @parsed_query.query_expression.table_expression.from_clause.tables.first

          equivalences = find_equivalences(join_conditions)

          equivalences.each do |equivalence|
            graph.add_edge(equivalence[:equivalence_left].to_sql, equivalence[:equivalence_right].to_sql)
            graph.add_edge(equivalence[:equivalence_right].to_sql, equivalence[:equivalence_left].to_sql)
          end

          graph.condensation_graph.vertices
        end

        def find_equivalences(clause)
          if clause.is_a?(SQLParser::Statement::QualifiedJoin)
            [
              find_equivalences_search_condition(
                clause.search_condition.search_condition
              ),
              find_equivalences(clause.left),
              find_equivalences(clause.right),
            ].flatten
          elsif clause.is_a?(SQLParser::Statement::JoinedTable)
            [
              find_equivalences(clause.left),
              find_equivalences(clause.right),
            ].flatten
          else
            []
          end
        end

        def find_equivalences_search_condition(search_condition)
          if search_condition.is_a?(SQLParser::Statement::And)
            [
              find_equivalences_search_condition(search_condition.left),
              find_equivalences_search_condition(search_condition.right),
            ].flatten
          elsif search_condition.is_a?(SQLParser::Statement::Equals)
            [
              {
                equivalence_left: search_condition.left,
                equivalence_right: search_condition.right,
              },
            ]
          else
            []
          end
        end
      end
    end
  end
end

require_relative 'group'
require_relative 'order_by'
require_relative 'select'
require_relative 'where'
require_relative 'having'
