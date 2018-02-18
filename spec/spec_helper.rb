require "bundler/setup"

unless ENV["CODECOV_TOKEN"].nil?
  require 'simplecov'
  SimpleCov.start

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "sql_assess"

require "pry"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    # begin
      SqlAssess::DatabaseConnection.new
    # rescue SqlAssess::DatabaseConnectionError
    #   puts "\e[31mCouldn't connect to database\e[0m"
    #   exit
    # end
  end

  config.before(:each) do
    SqlAssess::Runner.new(
      SqlAssess::DatabaseConnection.new
    ).clear_database
  end
end
