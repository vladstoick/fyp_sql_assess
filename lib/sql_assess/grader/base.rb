require "rubygems/text"

module SqlAssess::Grader
  class Base
    def self.grade_for(attribute:, student_attributes:, instructor_attributes:)
      "SqlAssess::Grader::#{attribute.to_s.camelcase}".constantize.new(
        student_attributes: student_attributes,
        instructor_attributes: instructor_attributes,
      ).rounded_grade
    end

    def initialize(student_attributes:, instructor_attributes:)
      @student_attributes = student_attributes
      @instructor_attributes = instructor_attributes
    end

    def levenshtein_distance(string_1, string_2)
      ld = Class.new.extend(Gem::Text).method(:levenshtein_distance)

      ld.call(string_1, string_2)
    end

    def rounded_grade
      grade.round(2)
    end

    private

    def grade_for_array
      return 1 if max_grade == 0

      instructor_unmatched_attributes = @instructor_attributes.dup
      student_unmatched_attributes = @student_attributes.dup

      student_unmatched_attributes = student_unmatched_attributes.keep_if do |student_unmatched_attribute|
        next 0 if instructor_unmatched_attributes.empty?

        match_score = instructor_unmatched_attributes.map do |instructor_unmatched_attribute|
          match_score(student_unmatched_attribute, instructor_unmatched_attribute)
        end

        best_match_score = match_score.each_with_index.max

        if best_match_score[0] == 2
          instructor_unmatched_attributes.delete_at(best_match_score[1])
          false
        else
          true
        end
      end

      matched_attributes = array_difference(
        @student_attributes,
        student_unmatched_attributes
      )

      matched_grade = matched_attributes.length * 2.0

      unmatched_grade = student_unmatched_attributes.sum do |student_unmatched_attribute|
        next 0 if instructor_unmatched_attributes.empty?

        match_score = instructor_unmatched_attributes.map do |instructor_unmatched_attribute|
          match_score(student_unmatched_attribute, instructor_unmatched_attribute)
        end

        best_match_score = match_score.each_with_index.max

        if best_match_score[0] > 0
          instructor_unmatched_attributes.delete_at(best_match_score[1])
        end

        best_match_score[0]
      end

      (matched_grade + unmatched_grade) / max_grade
    end

    # Difference with removing only once solution obtained from
    # https://stackoverflow.com/questions/30429659/ruby-difference-in-array-including-duplicates
    def array_difference(a, b)
      a = a.dup
      b.each { |del| a.slice!(a.index(del)) if a.include?(del) }
      a
    end

    def max_grade
      (@student_attributes.length + @instructor_attributes.length).to_d
    end
  end
end

require_relative "columns"
require_relative "order_by"
require_relative "where"
require_relative "distinct_filter"
require_relative "limit"
