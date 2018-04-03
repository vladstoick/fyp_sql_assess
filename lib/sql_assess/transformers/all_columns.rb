# frozen_string_literal: true

module SqlAssess
  module Transformers
    class AllColumns < Base
      def transform(query)
        @parsed_query = @parser.scan_str(query)

        if @parsed_query.query_expression.list.is_a?(SQLParser::Statement::All)
          transform_star_select
        end

        @parsed_query.to_sql
      end

      private

      def transform_star_select
        table_list = tables(@parsed_query.to_sql)

        new_columns = table_list.map do |table|
          columns_query = "SHOW COLUMNS from #{table}"
          columns = @connection.query(columns_query).map { |k| k['Field'] }

          columns.map do |column_name|
            SQLParser::Statement::QualifiedColumn.new(
              SQLParser::Statement::Table.new(table),
              SQLParser::Statement::Column.new(column_name)
            )
          end
        end.flatten

        @parsed_query.query_expression.instance_variable_set(
          '@list',
          SQLParser::Statement::SelectList.new(new_columns)
        )
      end
    end
  end
end
