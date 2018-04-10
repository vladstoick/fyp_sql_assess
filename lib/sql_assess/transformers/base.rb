# frozen_string_literal: true

require 'sql-parser'

module SqlAssess
  # Module for canonicalization transformers
  module Transformers
    # Base transformer. Provides implementation for traversing from, for
    # getting the list of tables.
    # @abstract
    # @author Vlad Stoica
    class Base
      def initialize(connection)
        @connection = connection
        @parser = SQLParser::Parser.new
      end

      # Transform method that must be implemented in subclasses
      def transform
        raise 'Implement this method in subclass'
      end

      # Gets the full list of tables from a query. It assumes that there are
      # no sub-queries involved
      # @return [Array<String>] the list of tables
      def tables(query)
        SqlAssess::Parsers::Tables.new(query).tables.map do |table|
          if table.key?(:join_type)
            table[:table][:table].remove('`')
          else
            table[:table].remove('`')
          end
        end
      end

      private

      def traverse_from(node)
        if node.is_a?(SQLParser::Statement::QualifiedJoin)
          node.class.new(
            traverse_from(node.left),
            traverse_from(node.right),
            SQLParser::Statement::On.new(
              transform_tree(node.search_condition.search_condition)
            )
          )
        elsif node.is_a?(SQLParser::Statement::JoinedTable)
          node.class.new(
            traverse_from(node.left),
            traverse_from(node.right)
          )
        else
          node
        end
      end
    end
  end
end

require_relative 'all_columns'
require_relative 'from_subquery'

require_relative 'not/base'
require_relative 'ambigous_columns/base'
require_relative 'between_predicate/base'
require_relative 'comparison_predicate/base'
require_relative 'equivalent_columns/base'
