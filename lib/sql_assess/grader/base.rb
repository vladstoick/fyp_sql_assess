require "rubygems/text"

module SqlAssess::Grader
  class Base
    def self.grade_for(attribute:, student_attributes:, instructor_attributes:)
      "SqlAssess::Grader::#{attribute.to_s.camelcase}".constantize.new(
        student_attributes: student_attributes,
        instructor_attributes: instructor_attributes
      ).rounded_grade
    end

    def levenshtein_distance(string_1, string_2)
      ld = Class.new.extend(Gem::Text).method(:levenshtein_distance)

      ld.call(string_1, string_2)
    end

    def rounded_grade
      grade.round(2)
    end
  end
end

require_relative "columns"
require_relative "order_by"
require_relative "where"
