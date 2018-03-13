module SqlAssess::Parsers
  class Where < Base
    def where
      if @parsed_query.query_expression.table_expression.where_clause.nil?
        {}
      else
        self.class.transform(@parsed_query.query_expression.table_expression.where_clause.search_condition)
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

    def self.merge(type, clause)
      if clause[:type] == type
        clause[:clauses]
      else
        clause
      end
    end
  end
end
