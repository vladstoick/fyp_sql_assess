# frozen_string_literal: true

module SqlAssess
  module Transformers
    # Module for ambigous columns transformers
    module AmbigousColumns
      # @author Vlad Stoica
      # Base class for transformers for ambiguous column. Provides implementation
      # for transforming columns
      class Base < SqlAssess::Transformers::Base
        # The list of ambiguous columns transformers
        def self.transformers
          [Select, From, Where, Group, OrderBy, Having]
        end

        private

        def transform_column(column)
          if column.is_a?(SQLParser::Statement::Column)
            table = find_table_for(column.name)

            SQLParser::Statement::QualifiedColumn.new(
              SQLParser::Statement::Table.new(table),
              column
            )
          elsif column.is_a?(SQLParser::Statement::Aggregate) && column.column.is_a?(SQLParser::Statement::Column)
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

        def transform_column_integer(column)
          if column.is_a?(SQLParser::Statement::Integer)
            @parsed_query.query_expression.list.columns[column.value - 1]
          else
            transform_column(column)
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

        def find_table_for(column_name)
          table_list = tables(@parsed_query.to_sql)

          table_list.detect do |table|
            columns_query = "SHOW COLUMNS from #{table}"
            columns = @connection.query(columns_query).map { |k| k['Field'] }
            columns.map(&:downcase).include?(column_name.downcase)
          end
        end
      end
    end
  end
end

require_relative 'from'
require_relative 'group'
require_relative 'order_by'
require_relative 'select'
require_relative 'where'
require_relative 'having'
