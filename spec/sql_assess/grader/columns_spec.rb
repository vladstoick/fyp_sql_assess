require "spec_helper"

RSpec.describe SqlAssess::Grader::Columns do
  subject do
    described_class.new(
      student_attributes: student_columns,
      instructor_attributes: instructor_columns
    )
  end

  context "example 1 - same columns" do
    let(:student_columns) { ["table1.column"] }
    let(:instructor_columns) { ["table1.column"] }

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "example 1 - two of same correct column for student" do
    let(:student_columns) { ["table1.column", "table1.column"] }
    let(:instructor_columns) { ["table1.column"] }

    it { expect(subject.rounded_grade).to eq(0.67) }
  end
end
