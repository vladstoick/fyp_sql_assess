require "sql_assess/transformers/base"
require "sql_assess/transformers/between_predicate"
require "sql_assess/transformers/all_columns"

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
      self.TRANSFORMERS.each do |transformer_class|
        query = transformer_class.new(connection).transform(query)
      end
    end
  end
end
