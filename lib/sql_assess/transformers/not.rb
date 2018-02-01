module SqlAssess::Transformers
  class Not < Base
    def transform(query)
      parsed_query = @parser.scan_str(query)

      if parsed_query.query_expression.table_expression.where_clause.present?
        parsed_query.query_expression.table_expression.where_clause.instance_variable_set(
          "@search_condition",
          transform_where_query(parsed_query.query_expression.table_expression.where_clause.search_condition)
        )
      end

      parsed_query.to_sql
    end

    private

    def transform_where_query(statement)
      if statement.is_a?(SQLParser::Statement::SearchCondition)
        statement.class.new(
          transform_where_query(statement.left),
          transform_where_query(statement.right)
        )
      elsif statement.is_a?(SQLParser::Statement::Not)
        transform_not_query(statement)
      else
        statement
      end
    end

    def transform_not_query(statement)
      # Greater
      if statement.value.is_a?(SQLParser::Statement::Greater)
        SQLParser::Statement::LessOrEquals.new(statement.value.left, statement.value.right)
      elsif statement.value.is_a?(SQLParser::Statement::GreaterOrEquals)
        SQLParser::Statement::Less.new(statement.value.left, statement.value.right)
      # Less
      elsif statement.value.is_a?(SQLParser::Statement::Less)
        SQLParser::Statement::GreaterOrEquals.new(statement.value.left, statement.value.right)
      elsif statement.value.is_a?(SQLParser::Statement::LessOrEquals)
        SQLParser::Statement::Greater.new(statement.value.left, statement.value.right)
      else
        statement
      end
    end
  end
end
