# frozen_string_literal: true

module SqlAssess
  module Transformers
    class AmbigousColumnsSelect < Base
      def transform(query)
        @query = query
        @parsed_query = @parser.scan_str(query)

        columns = @parsed_query.query_expression.list.columns.map do |column|
          transform_column(column)
        end

        @parsed_query.query_expression.list.instance_variable_set(
          '@columns',
          columns
        )

        @parsed_query.to_sql
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
