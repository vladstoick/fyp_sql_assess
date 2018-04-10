# frozen_string_literal: true

module SqlAssess
  module Transformers
    # @author Vlad Stoica
    # Equivalent columns transformer for subqueries in the FROM clause
    # @deprecated Do not use
    class FromSubquery < Base
      # Transforms the query
      #
      # @param [String] query the initial query
      # @return [String] the transformed query
      def transform(query)
        parsed_query = @parser.scan_str(query)

        join_clause = parsed_query.query_expression&.table_expression&.from_clause

        return query if join_clause.nil?

        new_tables = join_clause.tables.map do |table|
          transform_table(table)
        end

        parsed_query.query_expression.table_expression.from_clause.instance_variable_set(
          '@tables', new_tables
        )

        parsed_query.to_sql
      end

      private

      def transform_table(table)
        if table.is_a?(SQLParser::Statement::QualifiedJoin)
          table.class.new(
            transform_table(table.left),
            transform_table(table.right),
            SQLParser::Statement::On.new(
              table.search_condition.search_condition
            )
          )
        elsif table.is_a?(SQLParser::Statement::Subquery)
          SQLParser::Statement::Subquery.new(
            @parser.scan_str(
              SqlAssess::QueryTransformer.new(@connection).transform(
                table.query_specification.to_sql
              )
            )
          )
        else
          table
        end
      end
    end
  end
end
