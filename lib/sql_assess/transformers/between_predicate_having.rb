# frozen_string_literal: true

module SqlAssess
  module Transformers
    class BetweenPredicateHaving < Base
      def transform(query)
        parsed_query = @parser.scan_str(query)

        having_clause = parsed_query.query_expression.table_expression.having_clause

        return query if having_clause.nil?

        transformed_having_clause = transform_between_queries(having_clause.search_condition)

        parsed_query.query_expression.table_expression.having_clause.instance_variable_set(
          '@search_condition', transformed_having_clause
        )

        parsed_query.to_sql
      end

      private

      def transform_between_queries(predicate)
        if predicate.is_a?(SQLParser::Statement::SearchCondition)
          predicate.class.new(
            transform_between_queries(predicate.left),
            transform_between_queries(predicate.right)
          )
        elsif predicate.is_a?(SQLParser::Statement::Between)
          transform_between_query(predicate)
        else
          predicate
        end
      end

      def transform_between_query(predicate)
        SQLParser::Statement::And.new(
          SQLParser::Statement::GreaterOrEquals.new(predicate.left, predicate.min),
          SQLParser::Statement::LessOrEquals.new(predicate.left, predicate.max)
        )
      end
    end
  end
end
