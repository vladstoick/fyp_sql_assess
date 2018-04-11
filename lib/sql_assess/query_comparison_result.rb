# frozen_string_literal: true

require 'sql_assess/grader/base'

module SqlAssess
  # @author Vlad Stoica
  # The final result of an assesment
  # @!attribute [r] success
  #   @return [Boolean] whether the query returned the same results
  # @!attribute [r] attributes
  #   @return [Hash] The extracted attributes of the two queries. See
  #     {QueryAttributeExtractor}
  # @!attribute [r] attributes_grade
  #   @return [Hash] The grade for each component
  # @!attribute [r] grade
  #   @return [Double] The overall grade
  # @!attribute [r] message
  #   @return [String] Hint
  class QueryComparisonResult
    attr_reader :success, :attributes, :grade, :message

    def initialize(success:, attributes:)
      @success = success
      @attributes = attributes
      @message = determine_hints

      attributes_grade

      if @success == true
        @grade = 100.00
      else
        @grade = calculate_grade * 100.00
      end
    end

    def attributes_grade
      @attributes_grade ||= grade_components_percentages.keys.map do |key|
        key_hash = key == :where ? :where_tree : key
        [
          key,
          SqlAssess::Grader::Base.grade_for(
            attribute: key,
            student_attributes: attributes[:student][key_hash],
            instructor_attributes: attributes[:instructor][key_hash]
          ).to_d,
        ]
      end.to_h
    end

    private

    def calculate_grade
      attributes_grade.sum do |attribute, grade|
        grade * grade_components_percentages[attribute]
      end
    end

    def grade_components_percentages
      {
        tables: 1 / 8.0,
        columns: 1 / 8.0,
        group: 1 / 8.0,
        where: 1 / 8.0,
        distinct_filter: 1 / 8.0,
        limit: 1 / 8.0,
        order_by: 1 / 8.0,
        having: 1 / 8.0,
      }
    end

    def determine_hints
      if success == true
        'Congratulations! Your solutions is correct'
      else
        "Your query is not correct. #{message_for_attribute(first_wrong_component)}"
      end
    end

    def first_wrong_component
      grade_components_percentages.detect do |component|
        attributes_grade[component].to_d != 1
      end.first
    end

    def message_for_attribute(attribute)
      case attribute
      when :columns then 'Check what columns you are selecting.'
      when :tables then 'Are you sure you are selecting the right tables?'
      when :order_by then 'Are you ordering the rows correctly?'
      when :where then 'Looks like you are selecting the right columns, but you are not selecting only the correct rows.'
      when :distinct_filter then 'What about duplicates? What does the exercise say?'
      when :limit then 'Are you selecting the correct number of rows?'
      when :group then 'Are you grouping by the correct columns?'
      end
    end
  end
end
