module SqlAssess::Transformers
  class AmbigousColumns < Base
    def transform(query)
      @query = query
      @parsed_query = @parser.scan_str(query)

      columns = @parsed_query.query_expression.list.columns.map do |column|
        table = find_table_for(column.name)
        SQLParser::Statement::Column.new("#{table}.#{column.name}")
      end

      @parsed_query.query_expression.list.instance_variable_set(
        "@columns",
        columns
      )

      @parsed_query.to_sql
    end

    private

    def find_table_for(column_name)
      table_list = PgQuery.parse(@query).tables

      table_list.detect do |table|
        columns_query = "SHOW COLUMNS from #{table}"
        columns = @connection.query(columns_query).map { |k| k["Field"] }
        columns.include?(column_name)
      end
    end
  end
end
