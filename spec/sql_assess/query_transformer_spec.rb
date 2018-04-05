require "spec_helper"
require 'yaml'

RSpec.describe SqlAssess::QueryTransformer do
  subject { described_class.new(connection) }

  yaml = YAML.load_file("spec/fixtures/transformer_integration_tests.yml")

  yaml.each do |test|
    it "transform #{test['query']} to #{test['expected_result']}" do
      # Seed date
      connection.multiple_query(test["schema"])
      # Check if queries from file are correct
      connection.query(test["query"])
      connection.query(test["expected_result"])
      # Check transformation
      expect(subject.transform(test["query"])).to eq(test["expected_result"])
    end
  end
end
