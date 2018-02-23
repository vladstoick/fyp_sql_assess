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

    # Difference with removing only once solution obtained from
    # https://stackoverflow.com/questions/30429659/ruby-difference-in-array-including-duplicates
    def array_difference(a, b)
      a = a.dup
      b.each { |del| a.slice!(a.index(del)) if a.include?(del) }
      a
    end
  end
end

require_relative "columns"
require_relative "order_by"
require_relative "where"
require_relative "distinct_filter"
require_relative "limit"
