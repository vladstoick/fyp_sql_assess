# frozen_string_literal: true

module SqlAssess
  module Transformers
    module AmbigousColumns
      # @author Vlad Stoica
      # Ambiguous columns transformer for the GROUP clause
      class Group < Base
        # Transforms the query
        #
        # @param [String] query the initial query
        # @return [String] the transformed query
        #
        # @example
        #   With tables: t1(id1), t2(id3);
        #   SELECT `id1`, SUM(`id3`) FROM `t1`, `t2` GROUP BY `id1`
        #   is transformed
        #   SELECT `id1`, SUM(`id3`) FROM `t1`, `t2` GROUP BY `t1`.`id1`
        #
        # @example
        #   With tables: t1(id1), t2(id3);
        #   SELECT `id1`, SUM(`id3`) FROM `t1`, `t2` GROUP BY 1
        #   is transformed to
        #   SELECT `id1`, SUM(`id3`) FROM `t1`, `t2` GROUP BY `t1`.`id1`
        def transform(query)
          @query = query

          @parsed_query = @parser.scan_str(query)

          if @parsed_query.query_expression.table_expression.group_by_clause.nil?
            return @parsed_query.to_sql
          end

          columns = @parsed_query.query_expression.table_expression.group_by_clause.columns.map do |column|
            transform_column_integer(column)
          end

          @parsed_query.query_expression.table_expression.group_by_clause.instance_variable_set(
            '@columns',
            columns
          )

          @parsed_query.to_sql
        end
      end
    end
  end
end
