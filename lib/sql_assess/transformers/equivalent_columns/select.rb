# frozen_string_literal: true

module SqlAssess
  module Transformers
    module EquivalentColumns
      # @author Vlad Stoica
      # Equivalent columns transformer for columns list
      class Select < Base
        # Transforms the query
        #
        # @param [String] query the initial query
        # @return [String] the transformed query
        # @example
        #   SELECT `b`.`id`
        #   FROM `b` LEFT JOIN `a` ON `a`.`id` = `b`.`id`
        #
        #   is transformed to
        #
        #   SELECT `a`.`id`
        #   FROM `b` LEFT JOIN `a` ON `a`.`id` = `b`.`id`
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
