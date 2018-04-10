# frozen_string_literal: true

module SqlAssess
  module Transformers
    module EquivalentColumns
      # @author Vlad Stoica
      # Equivalent columns transformer for WHERE clause
      class Where < Base
        # Transforms the query
        #
        # @param [String] query the initial query
        # @return [String] the transformed query
        # @example
        #   SELECT *
        #   FROM `b` LEFT JOIN `a` ON `a`.`id` = `b`.`id`
        #   WHERE `b`.`id` > 3
        #
        #   is transformed to
        #
        #   SELECT *
        #   FROM `b` LEFT JOIN `a` ON `a`.`id` = `b`.`id`
        #   WHERE `a`.`id` > 3
        def transform(query)
          @parsed_query = @parser.scan_str(query)

          where_clause = @parsed_query.query_expression.table_expression.where_clause

          return query if where_clause.nil?

          transformed_where_clause = transform_tree(where_clause.search_condition)

          @parsed_query.query_expression.table_expression.where_clause.instance_variable_set(
            '@search_condition', transformed_where_clause
          )

          @parsed_query.to_sql
        end
      end
    end
  end
end
