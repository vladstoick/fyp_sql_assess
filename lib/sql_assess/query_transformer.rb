require "sql_assess/transformers/base"

module SqlAssess
  class QueryTransformer
    TRANSFORMERS = [
      # Columns
      Transformers::AllColumns,
      Transformers::EquivalentColumns,
      Transformers::AmbigousColumns,
      Transformers::AmbigousColumnsGroup,
      # Predicate
      Transformers::Not,
      Transformers::BetweenPredicate,
      Transformers::WhereComparisonPredicate,
      Transformers::HavingComparisonPredicate,
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
