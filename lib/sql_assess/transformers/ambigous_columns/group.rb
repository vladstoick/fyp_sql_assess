# frozen_string_literal: true

module SqlAssess
  module Transformers
    module AmbigousColumns
      class Group < Base
        def transform(query)
          @query = query

          @parsed_query = @parser.scan_str(query)

          if @parsed_query.query_expression.table_expression.group_by_clause.nil?
            return @parsed_query.to_sql
          end

          columns = @parsed_query.query_expression.table_expression.group_by_clause.columns.map do |column|
            transform_column_integer(column)
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
end
