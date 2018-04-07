# frozen_string_literal: true

module SqlAssess
  module Transformers
    class AmbigousColumnsWhere < Base
      def transform(query)
        @parsed_query = @parser.scan_str(query)

        where_clause = @parsed_query.query_expression.table_expression.where_clause

        return query if where_clause.nil?

        transformed_where_clause = transform_where(where_clause.search_condition)

        @parsed_query.query_expression.table_expression.where_clause.instance_variable_set(
          '@search_condition', transformed_where_clause
        )

        @parsed_query.to_sql
      end

      private

      def transform_where(predicate)
        if predicate.is_a?(SQLParser::Statement::SearchCondition)
          predicate.class.new(
            transform_where(predicate.left),
            transform_where(predicate.right)
          )
        elsif predicate.is_a?(SQLParser::Statement::ComparisonPredicate)
          predicate.class.new(
            transform_column(predicate.left),
            transform_column(predicate.right)
          )
        else
          predicate
        end
      end

      def transform_column(column)
        if column.is_a?(SQLParser::Statement::Column)
          table = find_table_for(column.name)

          SQLParser::Statement::QualifiedColumn.new(
            SQLParser::Statement::Table.new(table),
            column
          )
        elsif column.is_a?(SQLParser::Statement::Aggregate) && column.column.is_a?(SQLParser::Statement::Column)
          table = find_table_for(column.column.name)

          column.instance_variable_set(
            '@column',
            SQLParser::Statement::QualifiedColumn.new(
              SQLParser::Statement::Table.new(table),
              column.column
            )
          )

          column
        elsif column.is_a?(SQLParser::Statement::Arithmetic)
          column.class.new(
            transform_column(column.left),
            transform_column(column.right)
          )
        else
          column
        end
      end
    end
  end
end
