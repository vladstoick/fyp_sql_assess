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
          type: "EQUALS",
          left: "`id`",
          right: "1",
          sql: "`id` = 1",
        })
      end
    end

    context "less condition" do
      let(:query) { "SELECT * from table1 WHERE id < 1" }

      it "returns the correct result" do
        expect(subject.where).to eq({
          type: "LESS",
          left: "`id`",
          right: "1",
          sql: "`id` < 1",
        })
      end
    end
  end

  context "with an AND conidtion" do
    context "with two queries" do
      let(:query) { "SELECT * from table1 WHERE id = 1 AND id < 3" }

      it "returns the correct result" do
        expect(subject.where).to eq({
          type: "AND",
          clauses: [
            {
              type: "EQUALS",
              left: "`id`",
              right: "1",
              sql: "`id` = 1",
            },
            {
              type: "LESS",
              left: "`id`",
              right: "3",
              sql: "`id` < 3",
            }
          ]
        })
      end
    end

    context "with three queries" do
      let(:query) { "SELECT * from table1 WHERE id = 1 AND id < 3 AND id < 4" }

      it "returns the correct result" do
        expect(subject.where).to eq({
          type: "AND",
          clauses: [
            {
              type: "EQUALS",
              left: "`id`",
              right: "1",
              sql: "`id` = 1",
            },
            {
              type: "LESS",
              left: "`id`",
              right: "3",
              sql: "`id` < 3",
            },
            {
              type: "LESS",
              left: "`id`",
              right: "4",
              sql: "`id` < 4",
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
          type: "OR",
          clauses: [
            {
              type: "EQUALS",
              left: "`id`",
              right: "1",
              sql: "`id` = 1",
            },
            {
              type: "LESS",
              left: "`id`",
              right: "3",
              sql: "`id` < 3",
            }
          ]
        })
      end
    end

    context "with three queries" do
      let(:query) { "SELECT * from table1 WHERE id = 1 OR id < 3 OR id < 4" }

      it "returns the correct result" do
        expect(subject.where).to eq({
          type: "OR",
          clauses: [
            {
              type: "EQUALS",
              left: "`id`",
              right: "1",
              sql: "`id` = 1",
            },
            {
              type: "LESS",
              left: "`id`",
              right: "3",
              sql: "`id` < 3",
            },
            {
              type: "LESS",
              left: "`id`",
              right: "4",
              sql: "`id` < 4",
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
        type: "OR",
        clauses: [
          {
            type: "AND",
            clauses: [
              {
                type: "EQUALS",
                left: "`id`",
                right: "1",
                sql: "`id` = 1",
              },
              {
                type: "LESS",
                left: "`id`",
                right: "3",
                sql: "`id` < 3",
              },
            ]
          },
          {
            type: "LESS",
            left: "`id`",
            right: "4",
            sql: "`id` < 4",
          }
        ]
      })
    end
  end
end
