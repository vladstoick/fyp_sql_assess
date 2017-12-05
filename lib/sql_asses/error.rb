module SqlAsses
  class Error < StandardError
  end

  class DatabaseConnectionError < SqlAsses::Error
  end
end
