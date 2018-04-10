# frozen_string_literal: true

module SqlAssess
  module Transformers
    module ComparisonPredicate
      class Having < Base
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
