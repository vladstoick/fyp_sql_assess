# frozen_string_literal: true

module SqlAssess
  module Transformers
    class ComparisonPredicateHaving < Base
      def transform(query)
        parsed_query = @parser.scan_str(query)

        having_clause = parsed_query.query_expression.table_expression.having_clause

        return query if having_clause.nil?

        transformed_having_clause = transform_comparison_predicate_queries(having_clause.search_condition)

        parsed_query.query_expression.table_expression.having_clause.instance_variable_set(
          '@search_condition', transformed_having_clause
        )

        parsed_query.to_sql
      end

      private

      def transform_comparison_predicate_queries(predicate)
        if predicate.is_a?(SQLParser::Statement::SearchCondition)
          predicate.class.new(
            transform_comparison_predicate_queries(predicate.left),
            transform_comparison_predicate_queries(predicate.right)
          )
        elsif predicate.is_a?(SQLParser::Statement::ComparisonPredicate)
          transform_comparison_predicate_query(predicate)
        else
          predicate
        end
      end

      def transform_comparison_predicate_query(predicate)
        if predicate.is_a?(SQLParser::Statement::Greater)
          SQLParser::Statement::Less.new(
            predicate.right,
            predicate.left
          )
        elsif predicate.is_a?(SQLParser::Statement::GreaterOrEquals)
          SQLParser::Statement::LessOrEquals.new(
            predicate.right,
            predicate.left
          )
        else
          predicate
        end
      end
    end
  end
end
