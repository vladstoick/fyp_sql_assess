module SqlAssess::Transformers
  class WhereComparisonPredicate < Base
    def transform(query)
      parsed_query = @parser.scan_str(query)

      where_clause = parsed_query.query_expression.table_expression.where_clause

      return query if where_clause.nil?

      transformed_where_clause = transform_comparison_predicate_queries(where_clause.search_condition)

      parsed_query.query_expression.table_expression.where_clause.instance_variable_set(
        "@search_condition", transformed_where_clause
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
