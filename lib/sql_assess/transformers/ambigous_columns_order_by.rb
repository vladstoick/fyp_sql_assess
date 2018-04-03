# frozen_string_literal: true

module SqlAssess
  module Transformers
    class AmbigousColumnsOrderBy < Base
      def transform(query)
        @query = query

        @parsed_query = @parser.scan_str(query)

        return @parsed_query.to_sql if @parsed_query.order_by.nil?

        sort_specification = @parsed_query.order_by.sort_specification.map do |specification|
          if specification.column.is_a?(SQLParser::Statement::Column)
            table = find_table_for(specification.column.name)

            specification.class.new(
              SQLParser::Statement::QualifiedColumn.new(
                SQLParser::Statement::Table.new(table),
                specification.column
              )
            )

          elsif specification.column.is_a?(SQLParser::Statement::Integer)
            specification.class.new(
              @parsed_query.query_expression.list.columns[specification.column.value - 1]
            )

          else
            specification
          end
        end

        @parsed_query.order_by.instance_variable_set(
          '@sort_specification',
          sort_specification
        )

        @parsed_query.to_sql
      end

      private

      def find_table_for(column_name)
        table_list = tables(@parsed_query.to_sql)

        table_list.detect do |table|
          columns_query = "SHOW COLUMNS from #{table}"
          columns = @connection.query(columns_query).map { |k| k['Field'] }
          columns.include?(column_name)
        end
      end
    end
  end
end
