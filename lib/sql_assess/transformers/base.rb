module SqlAssess::Transformers
  class Base
    def initialize(connection)
      @connection = connection
      @parser = SQLParser::Parser.new
    end

    def transform
      raise "Implement this method in subclass"
    end
  end
end
