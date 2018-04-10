# frozen_string_literal: true

module SqlAssess
  module Parsers
    # Parser for the limit clause
    # @author Vlad Stoica
    class Limit < Base
      # @return [Hash{limit:, offset:}]. If offset is not present then return 0,
      #   if limit is not present then return inf.
      def limit
        if @parsed_query.query_expression&.table_expression&.limit_clause.present?
          {
            limit: @parsed_query.query_expression&.table_expression&.limit_clause&.limit,
            offset: @parsed_query.query_expression&.table_expression&.limit_clause&.offset || 0,
          }
        else
          {
            limit: 'inf',
            offset: 0,
          }
        end
      end
    end
  end
end
