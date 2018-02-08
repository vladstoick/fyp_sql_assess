module SqlAssess::Transformers
  class AllColumns < Base
    def transform(query)
      @parsed_query = @parser.scan_str(query)

      if @parsed_query.query_expression.list.is_a?(SQLParser::Statement::All)
        transform_star_select(query)
      end

      @parsed_query.to_sql
    end

    private

    def transform_star_select(query)
      table_list = PgQuery.parse(query).tables

      column_names = table_list.map do |table|
        columns_query = "SHOW COLUMNS from #{table}"
        @connection.query(columns_query).map { |k| k["Field"] }
      end.flatten

      sql_columns = column_names.map do |column_name|
        SQLParser::Statement::Column.new(column_name)
      end

      @parsed_query.query_expression.instance_variable_set(
        "@list",
        SQLParser::Statement::SelectList.new(sql_columns)
      )
    end
  end
end
