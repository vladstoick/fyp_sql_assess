module SqlAssess::Parsers
  class Where < Base
    class Type
      EQUALS = "EQUALS"
      LESS = "Less"
      AND = "AND"
      OR = "OR"
    end

    def where
      if @parsed_query.query_expression.table_expression.where_clause.nil?
        {}
      else
        transform(@parsed_query.query_expression.table_expression.where_clause.search_condition)
      end
    end

    private

    def transform(clause)
      if clause.is_a?(SQLParser::Statement::Equals)
        {
          type: Type::EQUALS,
          condition: clause.to_sql
        }
      elsif clause.is_a?(SQLParser::Statement::Less)
        {
          type: Type::LESS,
          condition: clause.to_sql
        }
      elsif clause.is_a?(SQLParser::Statement::And)
        transform_left = merge(Type::AND, transform(clause.left))
        transform_right = merge(Type::AND, transform(clause.right))
        {
          type: Type::AND,
          clauses: [
            transform_left,
            transform_right,
          ].flatten
        }
      elsif clause.is_a?(SQLParser::Statement::Or)
        transform_left = merge(Type::OR, transform(clause.left))
        transform_right = merge(Type::OR, transform(clause.right))
        {
          type: Type::OR,
          clauses: [
            transform_left,
            transform_right,
          ].flatten
        }
      end
    end

    def merge(type, clause)
      if clause[:type] == type
        clause[:clauses]
      else
        clause
      end
    end
  end
end
