# frozen_string_literal: true

module SqlAssess
  # Class for handling the attribute extraction process
  # @author Vlad Stoica
  class QueryAttributeExtractor
    # Extract the attributes of both the instructor's and student's queries
    #
    # @param [String] instructor_sql_query
    # @param [String] student_sql_query
    # @return [Hash] with two keys student and instructor. Each value has the format
    #   returned by {#extract_query}
    def extract(instructor_sql_query, student_sql_query)
      {
        student: extract_query(student_sql_query),
        instructor: extract_query(instructor_sql_query),
      }
    end

    # Extract the attributes of a query
    # @param [String] query
    # @return [Hash] that contains all attributes of a query.
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
