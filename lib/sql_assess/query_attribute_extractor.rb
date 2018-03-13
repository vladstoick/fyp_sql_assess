module SqlAssess
  class QueryAttributeExtractor
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
        distinct_filter: {
          instructor_distinct_filter: Parsers::DistinctFilter.new(instructor_sql_query).distinct_filter,
          student_distinct_filter: Parsers::DistinctFilter.new(student_sql_query).distinct_filter
        },
        limit: {
          instructor_limit: Parsers::Limit.new(instructor_sql_query).limit,
          student_limit: Parsers::Limit.new(student_sql_query).limit
        },
        group: {
          instructor_group: Parsers::Group.new(instructor_sql_query).group,
          student_group: Parsers::Group.new(student_sql_query).group
        },
      }
    end
  end
end
