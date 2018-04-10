# frozen_string_literal: true

module SqlAssess
  module Parsers
    # Parser for the FROM clause
    # @author Vlad Stoica
    class Tables < Base
      # @return [Array<Hash{type:, table:, sql:}, Hash{join_type:,table: Hash{type:, table:, sql:}, sql:}>]
      def tables
        if @parsed_query.query_expression&.table_expression&.from_clause.nil?
          []
        else
          @parsed_query.query_expression.table_expression.from_clause.tables.map do |expression|
            transform(expression)
          end.flatten
        end
      end

      private

      def transform(query)
        if query.is_a?(SQLParser::Statement::Table)
          {
            type: 'table',
            table: query.to_sql,
            sql: query.to_sql,
          }
        elsif query.is_a?(SQLParser::Statement::JoinedTable)
          hash = {
            join_type: query.class.name.split('::').last.underscore.humanize.upcase,
            table: transform(query.right),
            sql: "#{query.class.name.split('::').last.underscore.humanize.upcase} #{query.right.to_sql}",
          }

          if query.is_a?(SQLParser::Statement::QualifiedJoin)
            hash[:condition] = Where.transform(
              query.search_condition.search_condition
            )
            hash[:sql] = "#{query.class.name.split('::').last.underscore.humanize.upcase} #{query.right.to_sql} #{query.search_condition.to_sql}"
          end

          [transform(query.left), hash].flatten
        elsif query.is_a?(SQLParser::Statement::Subquery)
          {
            type: 'Subquery',
            sql: query.to_sql,
            attributes: SqlAssess::QueryAttributeExtractor.new.extract_query(query.query_specification.to_sql),
          }
        end
      end
    end
  end
end
