module SqlAsses
  class DatabaseQueryComparisonResult
    def initialize(success:)
      @success = success
    end

    def success?
      @success
    end
  end
end
