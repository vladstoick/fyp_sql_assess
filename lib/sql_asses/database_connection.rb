require "mysql2"

module SqlAsses
  class DatabaseConnection
    def initialize(host: "localhost", port: "3306", username: "root", database: nil)
      if database.nil?
        database = "local_db"
        @client = Mysql2::Client.new(
          host: host,
          port: port,
          username: username,
          init_command: "CREATE DATABASE IF NOT EXISTS #{database}"
        )
        @client.select_db(database)
      else
        @client = Mysql2::Client.new(
          host: host,
          port: port,
          username: username,
          database: database,
        )
      end


    rescue Mysql2::Error => exception
      raise DatabaseConnectionError.new(exception.message)
    end

    private

    def check_database_connection
    end
  end
end
