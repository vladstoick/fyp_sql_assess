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

    private

    def sort_specification_type(sort_specification)
      if sort_specification.is_a?(SQLParser::Statement::Ascending)
        'ASC'
      else
        'DESC'
      end
    end
  end
end
