# frozen_string_literal: true

require 'sql_assess/transformers/base'

module SqlAssess
  class QueryTransformer
    TRANSFORMERS = [
      # Subquery
      Transformers::FromSubquery,
      # Predicate
      Transformers::Not,
      Transformers::BetweenPredicate::Base.transformers,
      Transformers::ComparisonPredicate::Base.transformers,
      # Columns
      Transformers::AllColumns,
      Transformers::AmbigousColumns::Base.transformers,
      Transformers::EquivalentColumns,
    ].flatten.freeze

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
