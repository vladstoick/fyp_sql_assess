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
          if table.key?(:join_type)
            table[:table][:table].remove('`')
          else
            table[:table].remove('`')
          end
        end
      end

      def find_table_for(column_name)
        table_list = tables(@parsed_query.to_sql)

        table_list.detect do |table|
          columns_query = "SHOW COLUMNS from #{table}"
          columns = @connection.query(columns_query).map { |k| k['Field'] }
          columns.map(&:downcase).include?(column_name.downcase)
        end
      end

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
