require "bundler/setup"

unless ENV["CODECOV_TOKEN"].nil?
  require 'simplecov'
  SimpleCov.start

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "sql_assess"
require "timecop"
require "pry"

module SharedConnection
  def connection
    @shared_connection
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include SharedConnection

  config.before(:suite) do
    SqlAssess::DatabaseConnection.new(database: "local_db")
  end

  config.before(:all) do
    @shared_connection = SqlAssess::DatabaseConnection.new(database: "local_db")
  end

  config.before(:each) do
    @shared_connection.delete_database
  end
end
