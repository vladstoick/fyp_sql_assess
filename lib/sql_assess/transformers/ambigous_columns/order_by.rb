# frozen_string_literal: true

module SqlAssess
  module Transformers
    module AmbigousColumns
      # @author Vlad Stoica
      # Ambiguous columns transformer for the ORDER BY clause
      class OrderBy < Base
        # Transforms the query
        #
        # @param [String] query the initial query
        # @return [String] the transformed query
        #
        # @example
        #   With tables: t1(id1), t2(id3);
        #   SELECT `id1` FROM `t1`, `t2` ORDER BY 1
        #   is transformed to
        #   SELECT `id1` FROM `t1`, `t2` ORDER BY `t1`.`id1`
        def transform(query)
          @parsed_query = @parser.scan_str(query)

          return @parsed_query.to_sql if @parsed_query.order_by.nil?

          sort_specification = @parsed_query.order_by.sort_specification.map do |specification|
            specification.class.new(
              transform_column_integer(specification.column)
            )
          end

          @parsed_query.order_by.instance_variable_set(
            '@sort_specification',
            sort_specification
          )

          @parsed_query.to_sql
        end
      end
    end
  end
end
