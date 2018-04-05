require "spec_helper"

RSpec.describe SqlAssess::Grader::Tables do
  subject do
    described_class.new(
      student_attributes: attributes[:student][:tables],
      instructor_attributes: attributes[:instructor][:tables]
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

  context "with only base table equal" do
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

  context "with only base table and join equal" do
    let(:student_query) do
      <<-SQL
        SELECT a from table1 left join table2 on table2.id = table1.id
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT a from table1 left join table2 on table2.id = table1.id
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

  context "with two equal subquery" do
    let(:student_query) do
      <<-SQL
        SELECT id1 from (SELECT id1 from table1)
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT id1 from (SELECT id1 from table1)
      SQL
    end

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "with two slightly different subquery" do
    let(:student_query) do
      <<-SQL
        SELECT id1 from (SELECT id1 from table1)
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT id1 from (SELECT id2 from table1)
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.88) }
  end

  context "with one subquery and one table" do
    let(:student_query) do
      <<-SQL
        SELECT id1 from (SELECT id1 from table1)
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT id1 from table1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.0) }
  end

  context "with one subquery and one table" do
    let(:student_query) do
      <<-SQL
        SELECT id1 from table2 LEFT JOIN (SELECT id1 from table1) ON 1 = 1
      SQL
    end

    let(:instructor_query) do
      <<-SQL
        SELECT id1 from table2 LEFT JOIN (SELECT id1 from table2) ON 1 = 1
      SQL
    end

    it { expect(subject.rounded_grade).to eq(0.5) }
  end
end
