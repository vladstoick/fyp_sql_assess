module SqlAssess::Parsers
  class Having < Base
    def having
      if @parsed_query.query_expression.table_expression.having_clause.nil?
        {}
      else
        self.class.transform(@parsed_query.query_expression.table_expression.having_clause.search_condition)
      end
    end

    def having_tree
      if @parsed_query.query_expression.table_expression.having_clause.nil?
        {}
      else
        transform_tree(
          @parsed_query.query_expression.table_expression.having_clause.search_condition
        )
      end
    end

    def self.transform(clause)
      if clause.is_a?(SQLParser::Statement::ComparisonPredicate)
        {
          type: clause.class.name.split('::').last.underscore.humanize.upcase,
          left: clause.left.to_sql,
          right: clause.right.to_sql,
          sql: clause.to_sql,
        }
      elsif clause.is_a?(SQLParser::Statement::SearchCondition)
        type = clause.class.name.split('::').last.underscore.humanize.upcase
        transform_left = merge(type, transform(clause.left))
        transform_right = merge(type, transform(clause.right))
        {
          type: type,
          clauses: [
            transform_left,
            transform_right,
          ].flatten
        }
      end
    end

    private

    def transform_tree(clause)
      if clause.is_a?(SQLParser::Statement::ComparisonPredicate)
        {
          is_inner: false,
          type: clause.class.name.split('::').last.underscore.humanize.upcase,
          left: clause.left.to_sql,
          right: clause.right.to_sql,
          sql: clause.to_sql,
        }
      elsif clause.is_a?(SQLParser::Statement::SearchCondition)
        type = clause.class.name.split('::').last.underscore.humanize.upcase

        {
          is_inner: true,
          type: type,
          left_clause: transform_tree(clause.left),
          right_clause: transform_tree(clause.right),
        }
      end
    end

    def self.merge(type, clause)
      if clause[:type] == type
        clause[:clauses]
      else
        clause
      end
    end
  end
end
