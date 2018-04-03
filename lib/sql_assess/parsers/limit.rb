# frozen_string_literal: true

module SqlAssess
  module Parsers
    class Limit < Base
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
