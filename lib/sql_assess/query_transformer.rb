require "sql_assess/transformers/base"

module SqlAssess
  class QueryTransformer
    TRANSFORMERS = [
      Transformers::BetweenPredicate,
      Transformers::AllColumns,
      Transformers::Not,
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
