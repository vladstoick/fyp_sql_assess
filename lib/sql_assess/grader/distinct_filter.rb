# frozen_string_literal: true

module SqlAssess
  module Grader
    class DistinctFilter < Base
      def initialize(student_attributes:, instructor_attributes:)
        @student_distinct = student_attributes
        @instructor_distinct = instructor_attributes
      end

      def grade
        if @student_distinct == @instructor_distinct
          1.0
        elsif @student_distinct == 'DISTINCT' && @instructor_distinct == 'DISTINCTROW'
          0.5
        elsif @student_distinct == 'DISTINCTROW' && @instructor_distinct == 'DISTINCT'
          0.5
        else
          0
        end
      end
    end
  end
end
