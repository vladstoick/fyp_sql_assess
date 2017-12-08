require "sql_asses/transformers/base"
require "sql_asses/transformers/between_predicate"

module SqlAsses
  class DatabaseQueryTransformer
    TRANSFORMERS = [
      SqlAsses::Transformers::BetweenPredicate
    ]

    def initialize(connection)
      @connection = connection
    end

    def transform(query)
      self.TRANSFORMERS.each do |transformer_class|
        query = transformer_class.new(connection).transform(query)
      end
    end
  end
end
