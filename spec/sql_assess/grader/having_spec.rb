require "spec_helper"

RSpec.describe SqlAssess::Grader::Having do
  subject do
    described_class.new(
      student_attributes: attributes[:having][:student_having_tree],
      instructor_attributes: attributes[:having][:instructor_having_tree]
    )
  end

  let(:attributes) do
    SqlAssess::QueryAttributeExtractor.new(connection).extract(
       instructor_query, student_query
    )
  end

  context "with no having statements" do
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


  context "with no having for student, but having for teacher" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        HAVING a > 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0) }
  end


  context "with having for student, but no having for teacher" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        HAVING a > 1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0) }
  end

  context "with equal having" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        HAVING a > 1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        HAVING a > 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "with different having" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        HAVING a > 2
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        HAVING a > 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0) }
  end

  context "with different but one matching clause" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        HAVING a > 2 AND a > 1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        HAVING a > 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.33) }
  end

  context "with matching clauses but different boolean operator" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        HAVING a > 2 AND a > 1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        having a > 2 OR a > 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.5) }
  end

  context "with not matching clauses and different boolean operator" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1
        HAVING a > 2 AND a > 1 OR a > 3
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table2
        HAVING a > 2 OR a > 3
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.73) }
  end
end
