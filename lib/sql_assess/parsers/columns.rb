# frozen_string_literal: true

module SqlAssess
  module Parsers
    # @author Vlad Stoica
    # Parser for the columns
    class Columns < Base
      # @return [Array<String>] the list of columns selected
      def columns
        @parsed_query.query_expression.list.columns.map(&:to_sql)
      end
    end
  end
end
