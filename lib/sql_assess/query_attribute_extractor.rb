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
          student_where: Parsers::Where.new(student_sql_query).where,
          instructor_where_tree: Parsers::Where.new(instructor_sql_query).where_tree,
          student_where_tree: Parsers::Where.new(student_sql_query).where_tree,
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
        having: {
          instructor_having: Parsers::Having.new(instructor_sql_query).having,
          student_having: Parsers::Having.new(student_sql_query).having,
          instructor_having_tree: Parsers::Having.new(instructor_sql_query).having_tree,
          student_having_tree: Parsers::Having.new(student_sql_query).having_tree,
        },
      }
    end
  end
end
