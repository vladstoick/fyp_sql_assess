# frozen_string_literal: true

require 'rubygems/text'

module SqlAssess
  # Namespace that handles the grading part of the library
  module Grader
    # Base class for the grader
    # @author Vlad Stoica
    class Base
      # Returns the grade for a certain attribute given a list of attributes
      # @param [String] attribute component name (e.g. columns)
      # @param [Hash] student_attributes student's attributes for that component
      # @param [Hash] instructor_attributes instructor's attributes for that component
      def self.grade_for(attribute:, student_attributes:, instructor_attributes:)
        "SqlAssess::Grader::#{attribute.to_s.camelcase}".constantize.new(
          student_attributes: student_attributes,
          instructor_attributes: instructor_attributes
        ).rounded_grade
      end

      def initialize(student_attributes:, instructor_attributes:)
        @student_attributes = student_attributes
        @instructor_attributes = instructor_attributes
      end

      # The levenshtein distance between two strings
      # @param [String] string1
      # @param [String] string2
      # @return [Integer] the distance
      def levenshtein_distance(string1, string2)
        ld = Class.new.extend(Gem::Text).method(:levenshtein_distance)

        ld.call(string1, string2)
      end

      # Rounds the grade to two decimals. The subclasses must implement the
      # grade method.
      # @return [Double] rounded grade to two decimals
      def rounded_grade
        grade.round(2)
      end

      private

      def grade_for_array(instructor_attributes = @instructor_attributes, student_attributes = @student_attributes)
        max_grade = (student_attributes.length + instructor_attributes.length).to_d
        return 1 if max_grade.zero?

        instructor_unmatched_attributes = instructor_attributes.dup
        student_unmatched_attributes = student_attributes.dup

        student_unmatched_attributes = student_unmatched_attributes.keep_if do |student_unmatched_attribute|
          next 0 if instructor_unmatched_attributes.empty?

          match_score = instructor_unmatched_attributes.map do |instructor_unmatched_attribute|
            match_score(student_unmatched_attribute, instructor_unmatched_attribute)
          end

          best_match_score = match_score.each_with_index.max

          if best_match_score[0] == 1
            instructor_unmatched_attributes.delete_at(best_match_score[1])
            false
          else
            true
          end
        end

        matched_attributes = array_difference(
          student_attributes,
          student_unmatched_attributes
        )

        matched_grade = matched_attributes.length * 2.0

        unmatched_grade = student_unmatched_attributes.sum do |student_unmatched_attribute|
          next 0 if instructor_unmatched_attributes.empty?

          match_score = instructor_unmatched_attributes.map do |instructor_unmatched_attribute|
            match_score(student_unmatched_attribute, instructor_unmatched_attribute)
          end

          best_match_score = match_score.each_with_index.max

          if best_match_score[0].positive?
            instructor_unmatched_attributes.delete_at(best_match_score[1])
          end

          best_match_score[0]
        end

        (matched_grade + unmatched_grade) / max_grade
      end

      # Difference with removing only once solution obtained from
      # https://stackoverflow.com/questions/30429659/ruby-difference-in-array-including-duplicates
      def array_difference(array1, array2)
        array1 = array1.dup
        array2.each { |del| array1.slice!(array1.index(del)) if array1.include?(del) }
        array1
      end
    end
  end
end

require_relative 'columns'
require_relative 'order_by'
require_relative 'where'
require_relative 'distinct_filter'
require_relative 'limit'
require_relative 'tables'
require_relative 'group'
require_relative 'having'
