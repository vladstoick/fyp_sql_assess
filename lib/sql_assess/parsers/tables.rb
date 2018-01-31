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

    def transform(query)
      if query.is_a?(SQLParser::Statement::Table)
        query.to_sql
      elsif query.is_a?(SQLParser::Statement::JoinedTable)
        [
          transform(query.left),
          "#{query.class.name.split('::').last.underscore.humanize.upcase} #{transform(query.right)}"
        ].flatten
      end
    end
  end
end
