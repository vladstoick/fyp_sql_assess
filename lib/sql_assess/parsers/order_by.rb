# frozen_string_literal: true

module SqlAssess
  module Parsers
    class OrderBy < Base
      def order
        if @parsed_query.order_by.nil?
          []
        else
          @parsed_query.order_by.sort_specification.map(&:to_sql)
        end
      end
    end
  end
end
