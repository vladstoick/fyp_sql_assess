module SqlAssess::Transformers
  class AmbigousColumns < Base
    def transform(query)
      @query = query
      @parsed_query = @parser.scan_str(query)

      columns = @parsed_query.query_expression.list.columns.map do |column|
        if column.is_a?(SQLParser::Statement::Column)
          table = find_table_for(column.name)

          SQLParser::Statement::QualifiedColumn.new(
            SQLParser::Statement::Table.new(table),
            column
          )
        elsif column.is_a?(SQLParser::Statement::Aggregate) && column.column.is_a?(SQLParser::Statement::Column)
          table = find_table_for(column.column.name)

          column.instance_variable_set(
            "@column",
            SQLParser::Statement::QualifiedColumn.new(
              SQLParser::Statement::Table.new(table),
              column.column
            )
          )

          column
        else
          column
        end
      end

      @parsed_query.query_expression.list.instance_variable_set(
        "@columns",
        columns
      )

      @parsed_query.to_sql
    end

    private

    def find_table_for(column_name)
      table_list = PgQuery.parse(SQLVisitorForPostgres.new.visit(@parsed_query)).tables

      table_list.detect do |table|
        columns_query = "SHOW COLUMNS from #{table}"
        columns = @connection.query(columns_query).map { |k| k["Field"] }
        columns.include?(column_name)
      end
    end
  end
end
