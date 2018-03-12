require "spec_helper"

RSpec.describe SqlAssess::Grader::Tables do
  subject do
    described_class.new(
      student_attributes: attributes[:tables][:student_tables],
      instructor_attributes: attributes[:tables][:instructor_tables]
    )
  end

  let(:attributes) do
    SqlAssess::QueryAttributeExtractor.new(SqlAssess::DatabaseConnection.new).extract(
       instructor_query, student_query
    )
  end

  context "with only base table but different" do
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

    it { expect(subject.rounded_grade).to eq(0) }
  end

  context "with only base table and equal" do
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

  context "with base equal but join condition totally different" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1 left join table2 on table2.id = table1.id
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table1 left join table3 on table3.id = table1.id2
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.5) }
  end

  context "with base equal but join type different" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1 left join table2 on table2.id = table1.id
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table1 right join table2 on table2.id = table1.id
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.75) }
  end

  context "with base equal but join condition different" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1 left join table2 on table2.id = table1.id
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table1 left join table2 on table2.id2 = table1.id
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.75) }
  end

    context "with base equal but join condition and type different" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1 left join table2 on table2.id = table1.id
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table1 right join table2 on table2.id2 = table1.id
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.63) }
  end
end
