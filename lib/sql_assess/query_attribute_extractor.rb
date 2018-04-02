module SqlAssess
  class QueryAttributeExtractor
    def extract(instructor_sql_query, student_sql_query)
      {
        student: extract_query(student_sql_query),
        instructor: extract_query(instructor_sql_query),
      }
    end

    def extract_query(query)
      {
        columns: Parsers::Columns.new(query).columns,
        order_by: Parsers::OrderBy.new(query).order,
        where: Parsers::Where.new(query).where,
        where_tree: Parsers::Where.new(query).where_tree,
        tables: Parsers::Tables.new(query).tables,
        distinct_filter: Parsers::DistinctFilter.new(query).distinct_filter,
        limit: Parsers::Limit.new(query).limit,
        group: Parsers::Group.new(query).group,
        having: Parsers::Having.new(query).having,
        having_tree: Parsers::Having.new(query).having_tree,
      }
    end
  end
end
