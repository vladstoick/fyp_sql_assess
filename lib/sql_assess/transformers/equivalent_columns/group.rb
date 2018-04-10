# frozen_string_literal: true

module SqlAssess
  module Transformers
    module EquivalentColumns
      # @author Vlad Stoica
      # Equivalent columns transformer for GROUP clause
      class Group < Base
        # Transforms the query
        #
        # @param [String] query the initial query
        # @return [String] the transformed query
        # @example
        #   SELECT *
        #   FROM `b` LEFT JOIN `a` ON `a`.`id` = `b`.`id`
        #   GROUP BY `b`.`id`
        #
        #   is transformed to
        #
        #   SELECT *
        #   FROM `b` LEFT JOIN `a` ON `a`.`id` = `b`.`id`
        #   GROUP BY `a`.`id`
        def transform(query)
          @query = query

          @parsed_query = @parser.scan_str(query)

          if @parsed_query.query_expression.table_expression.group_by_clause.nil?
            return @parsed_query.to_sql
          end

          columns = @parsed_query.query_expression.table_expression.group_by_clause.columns.map do |column|
            transform_column(column)
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
