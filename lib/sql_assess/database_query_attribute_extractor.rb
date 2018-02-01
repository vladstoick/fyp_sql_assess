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
        where: {
          instructor_where: Parsers::Where.new(instructor_sql_query).where,
          student_where: Parsers::Where.new(student_sql_query).where
        },
        tables: {
          instructor_tables: Parsers::Tables.new(instructor_sql_query).tables,
          student_tables: Parsers::Tables.new(student_sql_query).tables
        },
      }
    end
  end
end
