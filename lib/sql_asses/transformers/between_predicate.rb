require 'sql-parser'

module SqlAsses::Transformers
  class BetweenPredicate < Base
    def transform(query)
      parsed_query = @parser.scan_str(query)

      where_clause = parsed_query.query_expression.table_expression.where_clause

      return query if where_clause.nil?

      transformed_where_clause = transform_between_queries(where_clause.search_condition)

      parsed_query.query_expression.table_expression.where_clause.instance_variable_set(
        "@search_condition", transformed_where_clause
      )

      parsed_query.to_sql
    end

    private

    def transform_between_queries(statement)
      if statement.is_a?(SQLParser::Statement::And)
        SQLParser::Statement::And.new(
          transform_between_queries(statement.left),
          transform_between_queries(statement.right)
        )
      elsif statement.is_a?(SQLParser::Statement::Or)
        # statement.left = transform_between_queries(statement.left)
        # statement.right = transform_between_queries(statement.right)
      elsif statement.is_a?(SQLParser::Statement::Between)
        transform_between_query(statement)
      else
        statement
      end
    end

    def transform_between_query(statement)
      unless statement.is_a?(SQLParser::Statement::Between)
        raise "Trying to transform a query that's not between"
      end

      SQLParser::Statement::And.new(
        SQLParser::Statement::Greater.new(statement.left, statement.min),
        SQLParser::Statement::Less.new(statement.left, statement.max)
      )
    end
  end
end
