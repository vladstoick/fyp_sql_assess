require "sql_assess/transformers/base"

module SqlAssess
  class DatabaseQueryTransformer
    TRANSFORMERS = [
      Transformers::BetweenPredicate,
      Transformers::AllColumns
    ]

    def initialize(connection)
      @connection = connection
    end

    def transform(query)
      TRANSFORMERS.each do |transformer_class|
        query = transformer_class.new(@connection).transform(query)
      end

      query
    end
  end
end
