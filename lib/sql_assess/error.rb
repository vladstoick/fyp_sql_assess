# frozen_string_literal: true

module SqlAssess
  class Error < StandardError
  end

  class DatabaseConnectionError < SqlAssess::Error
  end

  class DatabaseSchemaError < SqlAssess::Error
  end

  class DatabaseSeedError < SqlAssess::Error
  end

  class DatabaseQueryExecutionFailed < SqlAssess::Error
  end
end
