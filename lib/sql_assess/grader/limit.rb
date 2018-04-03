# frozen_string_literal: true

module SqlAssess
  module Grader
    class Limit < Base
      def initialize(student_attributes:, instructor_attributes:)
        @student_limit = student_attributes
        @instructor_limit = instructor_attributes
      end

      def grade
        @student_limit == @instructor_limit ? 1 : 0
      end
    end
  end
end
