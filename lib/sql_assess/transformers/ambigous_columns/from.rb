# frozen_string_literal: true

module SqlAssess
  module Transformers
    module AmbigousColumns
      class From < Base
        def transform(query)
          @parsed_query = @parser.scan_str(query)

          join_clause = @parsed_query.query_expression&.table_expression&.from_clause

          return query if join_clause.nil?

          new_tables = join_clause.tables.map do |table|
            traverse_from(table)
          end

          @parsed_query.query_expression.table_expression.from_clause.instance_variable_set(
            '@tables', new_tables
          )

          @parsed_query.to_sql
        end
      end
    end
  end
end
