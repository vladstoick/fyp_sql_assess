# frozen_string_literal: true

require 'mysql2'

module SqlAssess
  class DatabaseConnection
    def initialize(host: '127.0.0.1', port: '3306', username: 'root', database: nil)
      @client = Mysql2::Client.new(
        host: host,
        port: port,
        username: username,
        flags: Mysql2::Client::MULTI_STATEMENTS
      )

      if database.present?
        @parent_database = true
        @database = database
        @client.query("CREATE DATABASE IF NOT EXISTS `#{@database}`")
      else
        success = false
        attempt = 0
        until success
          if attempt.positive?
            @database = "#{Time.now.strftime('%H%M%S')}_#{attempt}"
          else
            @database = Time.now.strftime('%H%M%S').to_s
          end

          begin
            @client.query("CREATE DATABASE `#{@database}`")
            success = true
          rescue Mysql2::Error => exception
            raise exception unless exception.message.include?('database exists')
            success = false
            attempt += 1
          end
        end
      end

      @client.query("CREATE USER IF NOT EXISTS `#{@database}`;")
      @client.query("GRANT ALL PRIVILEGES ON `#{@database}`.* TO `#{@database}` WITH GRANT OPTION;")

      @restricted_client = Mysql2::Client.new(
        host: host,
        port: port,
        username: @database,
        flags: Mysql2::Client::MULTI_STATEMENTS
      )

      @restricted_client.select_db(@database)
      @client.select_db(@database)
    rescue Mysql2::Error => exception
      raise DatabaseConnectionError, exception.message
    end

    def query(query)
      @restricted_client.query(query)
    end

    def delete_database
      if @parent_database
        # disable foreign key checks before dropping the database
        @client.query('SET FOREIGN_KEY_CHECKS = 0')

        tables = query('SHOW tables')

        tables.each do |table|
          table_name = table['Tables_in_local_db']
          @client.query("DROP table #{table_name}")
        end

        @client.query('SET FOREIGN_KEY_CHECKS = 1')
      else
        @client.query("DROP DATABASE `#{@database}`")
        @client.query("DROP USER IF EXISTS `#{@database}`")
      end
    end

    def multiple_query(query)
      result = []

      result << @restricted_client.query(query)

      while @restricted_client.next_result
        result << @restricted_client.store_result
      end

      result
    end
  end
end
