module SqlAssess
  class Error < StandardError
  end

  class DatabaseConnectionError < SqlAssess::Error
  end
end
