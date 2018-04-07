# frozen_string_literal: true

module SqlAssess
  module Transformers
    class AmbigousColumnsGroup < Base
      def transform(query)
        @query = query

        @parsed_query = @parser.scan_str(query)

        if @parsed_query.query_expression.table_expression.group_by_clause.nil?
          return @parsed_query.to_sql
        end

        columns = @parsed_query.query_expression.table_expression.group_by_clause.columns.map do |column|
          if column.is_a?(SQLParser::Statement::Column)
            table = find_table_for(column.name)

            SQLParser::Statement::QualifiedColumn.new(
              SQLParser::Statement::Table.new(table),
              column
            )
          elsif column.is_a?(SQLParser::Statement::Integer)
            @parsed_query.query_expression.list.columns[column.value - 1]
          else
            column
          end
        end

        @parsed_query.query_expression.table_expression.group_by_clause.instance_variable_set(
          '@columns',
          columns
        )

        @parsed_query.to_sql
      end
    end
  end
end
