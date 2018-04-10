# frozen_string_literal: true

module SqlAssess
  module Transformers
    module AmbigousColumns
      class Select < Base
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
      end
    end
  end
end
