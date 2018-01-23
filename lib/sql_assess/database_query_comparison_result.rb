module SqlAssess
  class DatabaseQueryComparisonResult
    attr_reader :success, :attributes

    def initialize(success:, attributes:)
      @success = success
      @attributes = attributes
    end
  end
end
