require "spec_helper"

RSpec.describe SqlAssess::Grader::Where do
  subject do
    described_class.new(
      student_attributes: attributes[:student][:where_tree],
      instructor_attributes: attributes[:instructor][:where_tree]
    )
  end

  let(:attributes) do
    SqlAssess::QueryAttributeExtractor.new(connection).extract(
       instructor_query, student_query
    )
  end

  context "with no where statements" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
      SQL
    end

    it { expect(subject.rounded_grade).to eq(1) }
  end


  context "with no where for student, but where for teacher" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        WHERE a > 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0) }
  end


  context "with where for student, but no where for teacher" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        WHERE a > 1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0) }
  end

  context "with equal where" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        WHERE a > 1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        WHERE a > 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "with different where" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        WHERE a > 2
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        WHERE a > 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0) }
  end

  context "with different but one matching clause" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        WHERE a > 2 AND a > 1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        WHERE a > 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.33) }
  end

  context "with matching clauses but different boolean operator" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        WHERE a > 2 AND a > 1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        WHERE a > 2 OR a > 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.5) }
  end

  context "with not matching clauses and different boolean operator" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        WHERE a > 2 AND a > 1 OR a > 3
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        WHERE a > 2 OR a > 3
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.73) }
  end
end
