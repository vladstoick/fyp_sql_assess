module SqlAssess::Parsers
  class Columns < Base
    def columns
      if @parsed_query.query_expression.list.is_a?(SQLParser::Statement::All)
        ["*"]
      else
        @parsed_query.query_expression.list.columns.map(&:name)
      end
    end
  end
end
