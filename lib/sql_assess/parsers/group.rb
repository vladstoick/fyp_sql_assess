# frozen_string_literal: true

module SqlAssess
  module Parsers
    # Parser for the GROUP clause
    # @author Vlad Stoica
    class Group < Base
      # @return [Array<String>] the list of columns in the group clause
      def group
        if @parsed_query.query_expression.table_expression.group_by_clause.nil?
          []
        else
          @parsed_query.query_expression.table_expression.group_by_clause.columns.map(&:to_sql)
        end
      end
    end
  end
end
