module SqlAssess::Parsers
  class Base
    def initialize(query)
      @parsed_query = SQLParser::Parser.new.scan_str(query)
    end
  end
end

require_relative "columns"
