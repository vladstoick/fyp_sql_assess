require 'sql-parser'

module SqlAssess::Transformers
  class Base
    def initialize(connection)
      @connection = connection
      @parser = SQLParser::Parser.new
    end

    def transform
      raise "Implement this method in subclass"
    end

    def tables(query)
      SqlAssess::Parsers::Tables.new(query).tables.map do |table|
        table[:table].remove("`")
      end
    end
  end
end

require_relative 'all_columns'
require_relative 'between_predicate'
require_relative 'not'
require_relative 'ambigous_columns'
require_relative 'ambigous_columns_group'
require_relative 'ambigous_columns_order_by'
require_relative 'equivalent_columns'
require_relative 'where_comparison_predicate'
require_relative 'having_comparison_predicate'
require_relative 'join_comparison_predicate'
require_relative 'from_subquery'
