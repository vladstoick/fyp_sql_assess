# frozen_string_literal: true

module SqlAssess
  module Transformers
    module ComparisonPredicate
      class Base < SqlAssess::Transformers::Base
        def self.transformers
          [From, Where, Having]
        end

        private

        def transform_comparison_predicate(predicate)
          if predicate.is_a?(SQLParser::Statement::Greater)
            SQLParser::Statement::Less.new(
              predicate.right,
              predicate.left
            )
          elsif predicate.is_a?(SQLParser::Statement::GreaterOrEquals)
            SQLParser::Statement::LessOrEquals.new(
              predicate.right,
              predicate.left
            )
          else
            predicate
          end
        end

        def transform_tree(node)
          if node.is_a?(SQLParser::Statement::SearchCondition)
            node.class.new(
              transform_tree(node.left),
              transform_tree(node.right)
            )
          else
            transform_comparison_predicate(node)
          end
        end
      end
    end
  end
end

require_relative 'from'
require_relative 'where'
require_relative 'having'
