module SqlAssess
  class QueryComparisonResult
    attr_reader :success, :attributes

    def initialize(success:, attributes:)
      @success = success
      @attributes = attributes
    end
  end
end
