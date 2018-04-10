# frozen_string_literal: true

module SqlAssess
  # Namespace that handles the components extraction
  module Parsers
    # Base class for the parsers
    # @author Vlad Stoica
    class Base
      def initialize(query)
        @parsed_query = SQLParser::Parser.new.scan_str(query)
      end
    end
  end
end

require_relative 'columns'
require_relative 'order_by'
require_relative 'where'
require_relative 'tables'
require_relative 'distinct_filter'
require_relative 'limit'
require_relative 'group'
require_relative 'having'
