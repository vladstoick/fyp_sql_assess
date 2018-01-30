require "spec_helper"

RSpec.describe SqlAssess::Parsers::Where do
  subject { described_class.new(query) }

  context "with no where clause" do
    let(:query) { "SELECT * from table1" }

    it "returns an empty hash" do
      expect(subject.where).to eq({})
    end
  end

  context "with a single where condition" do
    context "equal condition" do
      let(:query) { "SELECT * from table1 WHERE id = 1" }

      it "returns the correct result" do
        expect(subject.where).to eq({
          type: SqlAssess::Parsers::Where::Type::EQUALS,
          condition: "`id` = 1"
        })
      end
    end

    context "less condition" do
      let(:query) { "SELECT * from table1 WHERE id < 1" }

      it "returns the correct result" do
        expect(subject.where).to eq({
          type: SqlAssess::Parsers::Where::Type::LESS,
          condition: "`id` < 1"
        })
      end
    end
  end

  context "with an AND conidtion" do
    context "with two queries" do
      let(:query) { "SELECT * from table1 WHERE id = 1 AND id < 3" }

      it "returns the correct result" do
        expect(subject.where).to eq({
          type: SqlAssess::Parsers::Where::Type::AND,
          clauses: [
            {
              type: SqlAssess::Parsers::Where::Type::EQUALS,
              condition: "`id` = 1"
            },
            {
              type: SqlAssess::Parsers::Where::Type::LESS,
              condition: "`id` < 3"
            }
          ]
        })
      end
    end

    context "with three queries" do
      let(:query) { "SELECT * from table1 WHERE id = 1 AND id < 3 AND id < 4" }

      it "returns the correct result" do
        expect(subject.where).to eq({
          type: SqlAssess::Parsers::Where::Type::AND,
          clauses: [
            {
              type: SqlAssess::Parsers::Where::Type::EQUALS,
              condition: "`id` = 1"
            },
            {
              type: SqlAssess::Parsers::Where::Type::LESS,
              condition: "`id` < 3"
            },
            {
              type: SqlAssess::Parsers::Where::Type::LESS,
              condition: "`id` < 4"
            }
          ]
        })
      end
    end
  end

  context "with an OR conidtion" do
    context "with two queries" do
      let(:query) { "SELECT * from table1 WHERE id = 1 OR id < 3" }

      it "returns the correct result" do
        expect(subject.where).to eq({
          type: SqlAssess::Parsers::Where::Type::OR,
          clauses: [
            {
              type: SqlAssess::Parsers::Where::Type::EQUALS,
              condition: "`id` = 1"
            },
            {
              type: SqlAssess::Parsers::Where::Type::LESS,
              condition: "`id` < 3"
            }
          ]
        })
      end
    end

    context "with three queries" do
      let(:query) { "SELECT * from table1 WHERE id = 1 OR id < 3 OR id < 4" }

      it "returns the correct result" do
        expect(subject.where).to eq({
          type: SqlAssess::Parsers::Where::Type::OR,
          clauses: [
            {
              type: SqlAssess::Parsers::Where::Type::EQUALS,
              condition: "`id` = 1"
            },
            {
              type: SqlAssess::Parsers::Where::Type::LESS,
              condition: "`id` < 3"
            },
            {
              type: SqlAssess::Parsers::Where::Type::LESS,
              condition: "`id` < 4"
            }
          ]
        })
      end
    end
  end

  context "with an AND and OR conditions" do
    let(:query) { "SELECT * from table1 WHERE id = 1 AND id < 3 OR id < 4" }

    it "returs the correct hash" do
      expect(subject.where).to eq({
        type: SqlAssess::Parsers::Where::Type::OR,
        clauses: [
          {
            type: SqlAssess::Parsers::Where::Type::AND,
            clauses: [
              {
                type: SqlAssess::Parsers::Where::Type::EQUALS,
                condition: "`id` = 1"
              },
              {
                type: SqlAssess::Parsers::Where::Type::LESS,
                condition: "`id` < 3"
              },
            ]
          },
          {
            type: SqlAssess::Parsers::Where::Type::LESS,
            condition: "`id` < 4"
          }
        ]
      })
    end
  end
end
