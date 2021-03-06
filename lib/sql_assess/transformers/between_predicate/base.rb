# frozen_string_literal: true

module SqlAssess
  module Transformers
    # Transformers for the between predicate
    module BetweenPredicate
      # @author Vlad Stoica
      # Base class for transformers for between predicate to two >= and <=
      class Base < SqlAssess::Transformers::Base
        # The list of between predicate transformers
        def self.transformers
          [From, Where, Having]
        end

        private

        def transform_between(between)
          SQLParser::Statement::And.new(
            SQLParser::Statement::GreaterOrEquals.new(between.left, between.min),
            SQLParser::Statement::LessOrEquals.new(between.left, between.max)
          )
        end

        def transform_tree(node)
          if node.is_a?(SQLParser::Statement::SearchCondition)
            node.class.new(
              transform_tree(node.left),
              transform_tree(node.right)
            )
          elsif node.is_a?(SQLParser::Statement::Between)
            transform_between(node)
          else
            node
          end
        end
      end
    end
  end
end

require_relative 'from'
require_relative 'where'
require_relative 'having'
