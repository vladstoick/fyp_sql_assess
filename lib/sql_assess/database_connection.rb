require "mysql2"

module SqlAssess
  class DatabaseConnection
    def initialize(host: "127.0.0.1", port: "3306", username: "root", database: nil)
      if database.nil?
        database = "local_db"
      end
      @client = Mysql2::Client.new(
        host: host,
        port: port,
        username: username,
        init_command: "CREATE DATABASE IF NOT EXISTS #{database}",
        flags: Mysql2::Client::MULTI_STATEMENTS
      )

      @client.select_db(database)
    rescue Mysql2::Error => exception
      raise DatabaseConnectionError.new(exception.message)
    end

    def query(query)
      @client.query(query)
    end
  end
end
