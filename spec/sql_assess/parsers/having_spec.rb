require "spec_helper"

RSpec.describe SqlAssess::Parsers::Having do
  subject { described_class.new(query) }

  context "#having" do
    context "with no having clause" do
      let(:query) { "SELECT * from table1" }

      it "returns an empty hash" do
        expect(subject.having).to eq({})
      end
    end

    context "with a single having condition" do
      context "equal condition" do
        let(:query) { "SELECT * from table1 HAVING id = 1" }

        it "returns the correct result" do
          expect(subject.having).to eq({
            type: "EQUALS",
            left: "`id`",
            right: "1",
            sql: "`id` = 1",
          })
        end
      end

      context "less condition" do
        let(:query) { "SELECT * from table1 HAVING id < 1" }

        it "returns the correct result" do
          expect(subject.having).to eq({
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
        let(:query) { "SELECT * from table1 HAVING id = 1 AND id < 3" }

        it "returns the correct result" do
          expect(subject.having).to eq({
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
        let(:query) { "SELECT * from table1 HAVING id = 1 AND id < 3 AND id < 4" }

        it "returns the correct result" do
          expect(subject.having).to eq({
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
        let(:query) { "SELECT * from table1 HAVING id = 1 OR id < 3" }

        it "returns the correct result" do
          expect(subject.having).to eq({
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
        let(:query) { "SELECT * from table1 HAVING id = 1 OR id < 3 OR id < 4" }

        it "returns the correct result" do
          expect(subject.having).to eq({
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
      let(:query) { "SELECT * from table1 HAVING id = 1 AND id < 3 OR id < 4" }

      it "returs the correct hash" do
        expect(subject.having).to eq({
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

  context '#having_tree' do
    context 'with no clause' do
      let(:query) { 'SELECT * from table1' }

      it { expect(subject.having_tree).to eq({}) }
    end

    context 'with a having clause' do
      let(:query) { "SELECT * from table1 HAVING #{conditions}" }

      context 'with only one condition' do
        let(:conditions) { 'a > 1' }

        it 'returns the appropiate tree' do
          expect(subject.having_tree).to eq({
            is_inner: false,
            type: "GREATER",
            left: "`a`",
            right: "1",
            sql: "`a` > 1"
          })
        end
      end

      context 'with two condition a ^ b' do
        let(:conditions) { 'a > 1 AND b > 1' }

        it 'returns the appropiate tree' do
          expect(subject.having_tree).to eq({
            is_inner: true,
            type: "AND",
            left_clause: {
              is_inner: false,
              type: "GREATER",
              left: "`a`",
              right: "1",
              sql: "`a` > 1"
            },
            right_clause: {
              is_inner: false,
              type: "GREATER",
              left: "`b`",
              right: "1",
              sql: "`b` > 1"
            }
          })
        end
      end

      context 'with three conditions a ^ b ^ c' do
        let(:conditions) { 'a > 1 AND b > 1 AND c > 1' }

        it 'returns the appropiate tree' do
          expect(subject.having_tree).to eq({
            is_inner: true,
            type: "AND",
            left_clause: {
              is_inner: true,
              type: "AND",
              left_clause: {
                is_inner: false,
                type: "GREATER",
                left: "`a`",
                right: "1",
                sql: "`a` > 1"
              },
              right_clause: {
                is_inner: false,
                type: "GREATER",
                left: "`b`",
                right: "1",
                sql: "`b` > 1"
              }
            },
            right_clause: {
              is_inner: false,
              type: "GREATER",
              left: "`c`",
              right: "1",
              sql: "`c` > 1"
            }
          })
        end
      end

      context 'with three conditions a ^ b V C' do
        let(:conditions) { 'a > 1 AND b > 1 OR c > 1' }

        it 'returns the appropiate tree' do
          expect(subject.having_tree).to eq({
            is_inner: true,
            type: "OR",
            left_clause: {
              is_inner: true,
              type: "AND",
              left_clause: {
                is_inner: false,
                type: "GREATER",
                left: "`a`",
                right: "1",
                sql: "`a` > 1"
              },
              right_clause: {
                is_inner: false,
                type: "GREATER",
                left: "`b`",
                right: "1",
                sql: "`b` > 1"
              }
            },
            right_clause: {
              is_inner: false,
              type: "GREATER",
              left: "`c`",
              right: "1",
              sql: "`c` > 1"
            }
          })
        end
      end

      context 'with three conditions a ^ (b V C)' do
        let(:conditions) { 'a > 1 AND (b > 1 OR c > 1)' }

        it 'returns the appropiate tree' do
          expect(subject.having_tree).to eq({
            is_inner: true,
            type: "AND",
            left_clause: {
              is_inner: false,
              type: "GREATER",
              left: "`a`",
              right: "1",
              sql: "`a` > 1"
            },
            right_clause: {
              is_inner: true,
              type: "OR",
              left_clause: {
                is_inner: false,
                type: "GREATER",
                left: "`b`",
                right: "1",
                sql: "`b` > 1"
              },
              right_clause: {
                is_inner: false,
                type: "GREATER",
                left: "`c`",
                right: "1",
                sql: "`c` > 1"
              }
            },
          })
        end
      end

      context 'with four conditions (a V c)^ (b V C)' do
        let(:conditions) { '(a > 1 OR c > 1) AND (b > 1 OR c > 1)' }

        it 'returns the appropiate tree' do
          expect(subject.having_tree).to eq({
            is_inner: true,
            type: "AND",
            left_clause: {
              is_inner: true,
              type: "OR",
              left_clause: {
                is_inner: false,
                type: "GREATER",
                left: "`a`",
                right: "1",
                sql: "`a` > 1"
              },
              right_clause: {
                is_inner: false,
                type: "GREATER",
                left: "`c`",
                right: "1",
                sql: "`c` > 1"
              }
            },
            right_clause: {
              is_inner: true,
              type: "OR",
              left_clause: {
                is_inner: false,
                type: "GREATER",
                left: "`b`",
                right: "1",
                sql: "`b` > 1"
              },
              right_clause: {
                is_inner: false,
                type: "GREATER",
                left: "`c`",
                right: "1",
                sql: "`c` > 1"
              }
            },
          })
        end
      end
    end
  end
end
