require "spec_helper"
require 'yaml'

RSpec.describe SqlAssess::QueryTransformer do
  subject { described_class.new(connection) }

  # yaml = YAML.load_file("spec/fixtures/transformer_integration_tests.yml")

  # yaml.each do |test|
  #   it "transform #{test['query']} to #{test['expected_result']}" do
  #     # Seed data
  #     connection.multiple_query(test["schema"])
  #     # Check if queries from file are correct
  #     connection.query(test["query"])
  #     connection.query(test["expected_result"])
  #     # Check transformation
  #     expect(subject.transform(test["query"])).to eq(test["expected_result"])
  #   end
  # end

  yaml2 = YAML.load_file("spec/fixtures/transformer_hacker_rank_integration_tests.yml")

  yaml2.each do |test|
    if test["support"] == false
      xit "#{test['name']}" do
        execute_query(test)
      end
    else
      it "#{test['name']}: transform #{test['query'].squish} to #{test['expected_result'].squish}" do
        execute_query(test)
      end
    end
  end

  def execute_query(test)
    # Seed data
    connection.multiple_query(test["schema"])
    # Check if queries from file are correct
    connection.query(test["query"])
    connection.query(test["expected_result"])
    # Check transformation
    expect(subject.transform(test["query"])).to eq(test["expected_result"].squish)
  end
end
