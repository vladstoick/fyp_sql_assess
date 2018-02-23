module SqlAssess::Parsers
  class DistinctFilter < Base
    def distinct_filter
      @parsed_query.query_expression.filter || "ALL"
    end
  end
end
