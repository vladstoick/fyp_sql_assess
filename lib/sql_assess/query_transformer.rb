# frozen_string_literal: true

require 'sql_assess/transformers/base'

module SqlAssess
  # Class for handling the canonicalization process
  # @author Vlad Stoica
  class QueryTransformer
    # The ordered list of transformers applied
    TRANSFORMERS = [
      # Subquery
      Transformers::FromSubquery,
      # Predicate
      Transformers::Not::Base.transformers,
      Transformers::BetweenPredicate::Base.transformers,
      Transformers::ComparisonPredicate::Base.transformers,
      # Columns
      Transformers::AllColumns,
      Transformers::AmbigousColumns::Base.transformers,
      Transformers::EquivalentColumns::Base.transformers,
    ].flatten.freeze

    def initialize(connection)
      @connection = connection
    end

# Apply sequentially all transformations to a query
#
# @param [String] query input query
# @return [String] canonicalized query
# @raise [CanonicalizationError] if any parsing errors are encountered
def transform(query)
  TRANSFORMERS.each do |transformer_class|
    query = transformer_class.new(@connection).transform(query)
  end

  query
rescue SQLParser::Parser::ScanError, Racc::ParseError
  raise CanonicalizationError
end
  end
end
