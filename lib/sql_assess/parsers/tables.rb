module SqlAssess::Parsers
  class Tables < Base
    def tables
      if @parsed_query.query_expression&.table_expression&.from_clause.nil?
        []
      else
        @parsed_query.query_expression.table_expression.from_clause.tables.map do |expression|
          transform(expression)
        end.flatten
      end
    end

    private

    def transform(query, is_base = true)
      if query.is_a?(SQLParser::Statement::Table)
        if is_base
          {
            type: "BASE",
            table: query.to_sql,
            sql: query.to_sql
          }
        else
          query.to_sql
        end
      elsif query.is_a?(SQLParser::Statement::JoinedTable)
        hash = {
          type: query.class.name.split('::').last.underscore.humanize.upcase,
          table: transform(query.right, false),
          sql: "#{query.class.name.split('::').last.underscore.humanize.upcase} #{query.right.to_sql}"
        }
        if query.is_a?(SQLParser::Statement::QualifiedJoin)
          hash[:condition] = Where.transform(
            query.search_condition.search_condition
          )
          hash[:sql] = "#{query.class.name.split('::').last.underscore.humanize.upcase} #{query.right.to_sql} #{query.search_condition.to_sql}"
        end

        [transform(query.left, is_base), hash].flatten
      end
    end
  end
end
