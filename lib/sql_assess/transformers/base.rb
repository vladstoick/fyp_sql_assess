# frozen_string_literal: true

require 'sql-parser'

module SqlAssess
  module Transformers
    class Base
      def initialize(connection)
        @connection = connection
        @parser = SQLParser::Parser.new
      end

      def transform
        raise 'Implement this method in subclass'
      end

      def tables(query)
        SqlAssess::Parsers::Tables.new(query).tables.map do |table|
          table[:table].remove('`')
        end
      end
    end
  end
end

require_relative 'all_columns'
require_relative 'between_predicate_where'
require_relative 'between_predicate_having'
require_relative 'between_predicate_from'
require_relative 'not'
require_relative 'ambigous_columns_select'
require_relative 'ambigous_columns_group'
require_relative 'ambigous_columns_order_by'
require_relative 'equivalent_columns'
require_relative 'comparison_predicate_where'
require_relative 'comparison_predicate_having'
require_relative 'comparison_predicate_from'
require_relative 'from_subquery'
