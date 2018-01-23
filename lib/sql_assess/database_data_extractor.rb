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

        result << {
          name: table_name,
          columns: data.first.map { |k, _| k },
          data: data.to_a
        }
      end

      result
    end
  end
end
