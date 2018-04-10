# frozen_string_literal: true

module SqlAssess
  module Transformers
    module EquivalentColumns
      class OrderBy < Base
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
