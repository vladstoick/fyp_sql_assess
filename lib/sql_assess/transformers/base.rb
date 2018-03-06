require 'sql-parser'
require 'pg_query'

module SqlAssess::Transformers
  class Base
    def initialize(connection)
      @connection = connection
      @parser = SQLParser::Parser.new
    end

    def transform
      raise "Implement this method in subclass"
    end
  end
end

require_relative 'all_columns'
require_relative 'between_predicate'
require_relative 'not'
require_relative 'ambigous_columns'
require_relative 'equivalent_columns'
