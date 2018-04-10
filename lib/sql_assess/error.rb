# frozen_string_literal: true

module SqlAssess
  # Base class for errors from the library
  # @author Vlad Stoica
  class Error < StandardError
  end

  # Error thrown when the library can't connect to the database
  # @author Vlad Stoica
  class DatabaseConnectionError < SqlAssess::Error
  end

  # Error thrown when the library encounters an error while executing the schema query
  # @author Vlad Stoica
  class DatabaseSchemaError < SqlAssess::Error
  end

  # Error thrown when the library encounters an error while executing the seed query
  # @author Vlad Stoica
  class DatabaseSeedError < SqlAssess::Error
  end

  # Error thrown when the library encounters an error while executing the instructor's or student's query
  # @author Vlad Stoica
  class DatabaseQueryExecutionFailed < SqlAssess::Error
  end
end
