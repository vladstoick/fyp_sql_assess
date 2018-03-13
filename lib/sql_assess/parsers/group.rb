module SqlAssess::Parsers
  class Group < Base
    def group
      if @parsed_query.query_expression.table_expression.group_by_clause.nil?
        return []
      else
        @parsed_query.query_expression.table_expression.group_by_clause.columns.map(&:to_sql)
      end
    end
  end
end
