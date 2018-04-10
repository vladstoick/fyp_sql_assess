# frozen_string_literal: true

module SqlAssess
  module Transformers
    module Not
      class Base < SqlAssess::Transformers::Base
        def self.transformers
          [From, Where, Having]
        end

        private

        def transform_not(not_statement)
          # Greater
          if not_statement.value.is_a?(SQLParser::Statement::Greater)
            SQLParser::Statement::LessOrEquals.new(not_statement.value.left, not_statement.value.right)
          elsif not_statement.value.is_a?(SQLParser::Statement::GreaterOrEquals)
            SQLParser::Statement::Less.new(not_statement.value.left, not_statement.value.right)
          # Less
          elsif not_statement.value.is_a?(SQLParser::Statement::Less)
            SQLParser::Statement::GreaterOrEquals.new(not_statement.value.left, not_statement.value.right)
          elsif not_statement.value.is_a?(SQLParser::Statement::LessOrEquals)
            SQLParser::Statement::Greater.new(not_statement.value.left, not_statement.value.right)
          else
            not_statement
          end
        end

        def transform_tree(node)
          if node.is_a?(SQLParser::Statement::SearchCondition)
            node.class.new(
              transform_tree(node.left),
              transform_tree(node.right)
            )
          elsif node.is_a?(SQLParser::Statement::Not)
            transform_not(node)
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
