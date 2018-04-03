# frozen_string_literal: true

module SqlAssess
  module Parsers
    class DistinctFilter < Base
      def distinct_filter
        @parsed_query.query_expression.filter || 'ALL'
      end
    end
  end
end
