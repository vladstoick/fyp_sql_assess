require "sql_assess/transformers/base"

module SqlAssess
  class QueryTransformer
    TRANSFORMERS = [
      # Subquery
      Transformers::FromSubquery,
      # Columns
      Transformers::AllColumns,
      Transformers::AmbigousColumns,
      Transformers::AmbigousColumnsGroup,
      Transformers::EquivalentColumns,
      # Predicate
      Transformers::Not,
      Transformers::BetweenPredicate,
      Transformers::JoinComparisonPredicate,
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
