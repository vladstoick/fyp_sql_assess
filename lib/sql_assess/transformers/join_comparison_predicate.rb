module SqlAssess::Transformers
  class JoinComparisonPredicate < Base
    def transform(query)
      parsed_query = @parser.scan_str(query)

      join_clause = parsed_query.query_expression&.table_expression&.from_clause

      return query if join_clause.nil?

      new_tables = join_clause.tables.map do|table|
        transform_comparison_predicate_table(table)
      end

      parsed_query.query_expression.table_expression.from_clause.instance_variable_set(
        "@tables", new_tables
      )

      parsed_query.to_sql
    end

    private

    def transform_comparison_predicate_table(table)
      if table.is_a?(SQLParser::Statement::QualifiedJoin)
        table.class.new(
          transform_comparison_predicate_table(table.left),
          transform_comparison_predicate_table(table.right),
          SQLParser::Statement::On.new(
            transform_comparison_predicate_condition(table.search_condition.search_condition)
          )
        )
       elsif table.is_a?(SQLParser::Statement::JoinedTable)
        predicate.class.new(
          transform_comparison_predicate_table(table.left),
          transform_comparison_predicate_table(table.right),
        )
      else
        table
      end
    end

    def transform_comparison_predicate_condition(predicate)
      if predicate.is_a?(SQLParser::Statement::SearchCondition)
        predicate.class.new(
          transform_comparison_predicate_condition(predicate.left),
          transform_comparison_predicate_condition(predicate.right)
        )
      elsif predicate.is_a?(SQLParser::Statement::ComparisonPredicate)
        transform_comparison_predicate(predicate)
      else
        predicate
      end
    end

    def transform_comparison_predicate(predicate)
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
