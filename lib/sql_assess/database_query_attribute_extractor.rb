module SqlAssess
  class DatabaseQueryAttributeExtractor
    def initialize(connection)
      @connection = connection
    end

    def extract(instructor_sql_query, student_sql_query)
      {
        columns: {
          instructor_columns: Parsers::Columns.new(instructor_sql_query).columns,
          student_columns: Parsers::Columns.new(student_sql_query).columns,
        },
        order_by: {
          instructor_order_by: Parsers::OrderBy.new(instructor_sql_query).order,
          student_order_by: Parsers::OrderBy.new(student_sql_query).order
        },
      }
    end
  end
end
