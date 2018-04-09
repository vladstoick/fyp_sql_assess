# frozen_string_literal: true

require 'sql_assess/transformers/base'

module SqlAssess
  class QueryTransformer
    TRANSFORMERS = [
      # Subquery
      Transformers::FromSubquery,
      # Predicate
      Transformers::Not,
      Transformers::BetweenPredicateWhere,
      Transformers::BetweenPredicateHaving,
      Transformers::ComparisonPredicateFrom,
      Transformers::ComparisonPredicateWhere,
      Transformers::ComparisonPredicateHaving,
      # Columns
      Transformers::AllColumns,
      Transformers::AmbigousColumnsSelect,
      Transformers::AmbigousColumnsWhere,
      Transformers::AmbigousColumnsGroup,
      Transformers::AmbigousColumnsOrderBy,
      Transformers::EquivalentColumns,
    ].freeze

    def initialize(connection)
      @connection = connection
    end

    def transform(query)
      TRANSFORMERS.each do |transformer_class|
        query = transformer_class.new(@connection).transform(query)
        # binding.pry
      end

      query
    end
  end
end
