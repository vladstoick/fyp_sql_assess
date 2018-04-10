# frozen_string_literal: true

module SqlAssess
  module Transformers
    module BetweenPredicate
      # Between transformer for Having clause
      # @author Vlad Stoica
      class Having < Base
        # Transforms the query
        #
        # @param [String] query the initial query
        # @return [String] the transformed query
        # @example
        #   With tables: t1(id1), t2(id3);
        #   SELECT `id1`, SUM(`id3`) FROM `t1`, `t2` HAVING SUM(`id3`) BETWEEN 1 AND 3 GROUP BY 1
        #   is transformed to
        #   SELECT `id1`, SUM(`id3`) FROM `t1`, `t2` HAVING SUM(`id3`) >=1 AND HAVING SUM(`id3`) <= 3 GROUP BY 1
        def transform(query)
          parsed_query = @parser.scan_str(query)

          having_clause = parsed_query.query_expression.table_expression.having_clause

          return query if having_clause.nil?

          transformed_having_clause = transform_tree(having_clause.search_condition)

          parsed_query.query_expression.table_expression.having_clause.instance_variable_set(
            '@search_condition', transformed_having_clause
          )

          parsed_query.to_sql
        end
      end
    end
  end
end
