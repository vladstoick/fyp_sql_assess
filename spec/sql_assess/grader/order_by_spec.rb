require "spec_helper"

RSpec.describe SqlAssess::Grader::OrderBy do
  subject do
    described_class.new(
      student_attributes: attributes[:student][:order_by],
      instructor_attributes: attributes[:instructor][:order_by]
    )
  end

  before do
    connection.query("CREATE TABLE table1 (id1 integer, id2 integer)")
    connection.query("CREATE TABLE table2 (id3 integer, id4 integer)")
  end

  let(:attributes) do
    SqlAssess::QueryAttributeExtractor.new.extract(
       instructor_query, student_query
    )
  end

  context "with no order by" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "with one equal order by" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        ORDER BY a ASC
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table1
        ORDER BY a ASC
      SQL
    end

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "with two equal order by" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        ORDER BY a, b
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table1
        ORDER BY a, b
      SQL
    end

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "with one equal and one different order by" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        ORDER BY a, b
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table1
        ORDER BY a, c
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.5) }
  end

    context "with one equal and one different order by" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        ORDER BY a, b
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table1
        ORDER BY a
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.67) }
  end
end
