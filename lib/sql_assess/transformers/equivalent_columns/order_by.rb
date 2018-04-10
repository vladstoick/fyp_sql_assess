# frozen_string_literal: true

module SqlAssess
  module Transformers
    module EquivalentColumns
      # @author Vlad Stoica
      # Equivalent columns transformer for Order clause
      class OrderBy < Base
        # Transforms the query
        #
        # @param [String] query the initial query
        # @return [String] the transformed query
        # @example
        #   SELECT *
        #   FROM `b` LEFT JOIN `a` ON `a`.`id` = `b`.`id`
        #   ORDER BY `b`.`id`
        #
        #   is transformed to
        #
        #   SELECT *
        #   FROM `b` LEFT JOIN `a` ON `a`.`id` = `b`.`id`
        #   ORDER BY `a`.`id`
        def transform(query)
          @parsed_query = @parser.scan_str(query)

          return @parsed_query.to_sql if @parsed_query.order_by.nil?

          sort_specification = @parsed_query.order_by.sort_specification.map do |specification|
            specification.class.new(
              transform_column(specification.column)
            )
          end

          @parsed_query.order_by.instance_variable_set(
            '@sort_specification',
            sort_specification
          )

          @parsed_query.to_sql
        end
      end
    end
  end
end
