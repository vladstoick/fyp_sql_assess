module SqlAssess::Parsers
  class Columns < Base
    def columns
      @parsed_query.query_expression.list.columns.map(&:to_sql)
    end
  end
end
