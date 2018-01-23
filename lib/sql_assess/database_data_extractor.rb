require "mysql2"

module SqlAssess
  class DatabaseDataExtractor
    def initialize(connection)
      @connection = connection
    end

    def run
      result = []
      tables = @connection.query("SHOW tables;")

      tables.each do |table|
        table_name = table.first.last

        data = @connection.query("SELECT * from #{table_name}")
        columns = @connection.query("SHOW columns from #{table_name}").to_a.map do |column|
          {
            name: column.fetch("Field"),
            type: column.fetch("Type")
          }
        end

        result << {
          name: table_name,
          columns: columns,
          data: data.to_a
        }
      end

      result
    end
  end
end
