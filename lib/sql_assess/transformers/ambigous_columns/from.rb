# frozen_string_literal: true

module SqlAssess
  module Transformers
    module AmbigousColumns
      # @author Vlad Stoica
      # Ambiguous columns transformer for the FROM clause
      class From < Base
        # Transforms the query
        #
        # @param [String] query the initial query
        # @return [String] the transformed query
        #
        # @example
        #   With tables: t1(id1), t2(id3);
        #   SELECT `id1` FROM `t1` LEFT JOIN `t2` on `id1` = `id3`
        #   is transformed to
        #   SELECT `id1` FROM `t1` LEFT JOIN `t2` on `t1`.`id1` = `t2`.`id3`
        def transform(query)
          @parsed_query = @parser.scan_str(query)

          join_clause = @parsed_query.query_expression&.table_expression&.from_clause

          return query if join_clause.nil?

          new_tables = join_clause.tables.map do |table|
            traverse_from(table)
          end

          @parsed_query.query_expression.table_expression.from_clause.instance_variable_set(
            '@tables', new_tables
          )

          @parsed_query.to_sql
        end
      end
    end
  end
end
