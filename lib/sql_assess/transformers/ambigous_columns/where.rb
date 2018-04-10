# frozen_string_literal: true

module SqlAssess
  module Transformers
    module AmbigousColumns
      # @author Vlad Stoica
      # Ambiguous columns transformer for the WHERE clause
      class Where < Base
        # Transforms the query
        #
        # @param [String] query the initial query
        # @return [String] the transformed query
        #
        # @example
        #   With tables: t1(id1), t2(id3);
        #   SELECT `id1` FROM `t1`, `t2` WHERE `id3` > 3
        #   is transformed to
        #   SELECT `id1` FROM `t1`, `t2` WHERE `t2`.`id3` > 3
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
