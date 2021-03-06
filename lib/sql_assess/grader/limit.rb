# frozen_string_literal: true

module SqlAssess
  module Grader
    # Grader for LIMIT clause
    # @author Vlad Stoica
    class Limit < Base
      def initialize(student_attributes:, instructor_attributes:)
        @student_limit = student_attributes
        @instructor_limit = instructor_attributes
      end

      private

      def grade
        grade = 0

        grade += 0.5 if @student_limit[:limit] == @instructor_limit[:limit]

        grade += 0.5 if @student_limit[:offset] == @instructor_limit[:offset]

        grade
      end
    end
  end
end
