require "spec_helper"

RSpec.describe SqlAssess::Grader::Group do
  subject do
    described_class.new(
      student_attributes: student_group,
      instructor_attributes: instructor_group
    )
  end

  context "example 1 - same columns" do
    let(:student_group) { ["table1.column"] }
    let(:instructor_group) { ["table1.column"] }

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "example 2 - two of same correct column for student" do
    let(:student_group) { ["table1.column", "table1.column"] }
    let(:instructor_group) { ["table1.column"] }

    it { expect(subject.rounded_grade).to eq(0.67) }
  end

  context "example 3 - one correct column and one incorrect for student" do
    let(:student_group) { ["table1.column", "table1.column2"] }
    let(:instructor_group) { ["table1.column"] }

    it { expect(subject.rounded_grade).to eq(0.67) }
  end

  context "example 4 - slightly different columns" do
    let(:student_group) { ["table1.column"] }
    let(:instructor_group) { ["table1.column_2"] }

    it { expect(subject.rounded_grade).to eq(0.5) }
  end

  context "example 5 - totally different columns" do
    let(:student_group) { ["table1.column"] }
    let(:instructor_group) { ["table2.column_2"] }

    it { expect(subject.rounded_grade).to eq(0) }
  end
end
