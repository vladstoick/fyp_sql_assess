# frozen_string_literal: true

module SqlAssess
  module Parsers
    # Parser for the distinct filter
    # @author Vlad Stoica
    class DistinctFilter < Base
      # @return [String] distinct filter or ALL if no distinc filter is mentioned
      def distinct_filter
        @parsed_query.query_expression.filter || 'ALL'
      end
    end
  end
end
