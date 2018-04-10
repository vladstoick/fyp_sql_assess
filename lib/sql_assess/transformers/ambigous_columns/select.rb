# frozen_string_literal: true

module SqlAssess
  module Transformers
    module AmbigousColumns
      # @author Vlad Stoica
      # Ambiguous columns transformer for the Select clause
      class Select < Base
        # Transforms the query
        #
        # @param [String] query the initial query
        # @return [String] the transformed query
        # @example
        #   With tables: t1(id1), t2(id3);
        #   SELECT `id1` FROM `t1`, `t2`
        #   is transformed to
        #   SELECT `t1`.`id1` FROM `t1`, `t2`
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
