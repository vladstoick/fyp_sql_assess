# frozen_string_literal: true

module SqlAssess
  module Parsers
    class OrderBy < Base
      def order
        if @parsed_query.order_by.nil?
          []
        else
          @parsed_query.order_by.sort_specification.each_with_index.map do |column, i|
            {
              column: column.to_sql,
              position: i,
            }
          end
        end
      end
    end
  end
end
