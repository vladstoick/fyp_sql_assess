# frozen_string_literal: true

require 'sql_assess/transformers/base'

module SqlAssess
  class QueryTransformer
    TRANSFORMERS = [
      # Subquery
      Transformers::FromSubquery,
      # Columns
      Transformers::AllColumns,
      Transformers::AmbigousColumnsSelect,
      Transformers::AmbigousColumnsGroup,
      Transformers::AmbigousColumnsOrderBy,
      Transformers::EquivalentColumns,
      # Predicate
      Transformers::Not,
      Transformers::BetweenPredicateWhere,
      Transformers::BetweenPredicateHaving,
      Transformers::ComparisonPredicateFrom,
      Transformers::ComparisonPredicateWhere,
      Transformers::ComparisonPredicateHaving,
    ].freeze

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
