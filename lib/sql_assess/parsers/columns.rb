# frozen_string_literal: true

module SqlAssess
  module Parsers
    class Columns < Base
      def columns
        @parsed_query.query_expression.list.columns.map(&:to_sql)
      end
    end
  end
end
