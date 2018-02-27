module SqlAssess::Parsers
  class OrderBy < Base
    def order
      if @parsed_query.order_by.nil?
        []
      else
        @parsed_query.order_by.sort_specification.map do |sort_specification|
          sort_specification.to_sql
        end
      end
    end
  end
end
