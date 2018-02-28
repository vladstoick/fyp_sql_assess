require "spec_helper"

RSpec.describe SqlAssess::Grader::DistinctFilter do
  subject do
    described_class.new(
      student_attributes: student_distinct_filter,
      instructor_attributes: instructor_distinct_filter
    )
  end

  context "same filter" do
    let(:student_distinct_filter) { "ALL" }
    let(:instructor_distinct_filter) { "ALL" }

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "different filter" do
    let(:student_distinct_filter) { "ALL" }
    let(:instructor_distinct_filter) { "DISTINCT" }

    it { expect(subject.rounded_grade).to eq(0) }
  end

  context "different filter - but both including distinct" do
    let(:student_distinct_filter) { "DISTINCTROW" }
    let(:instructor_distinct_filter) { "DISTINCT" }

    it { expect(subject.rounded_grade).to eq(0.5) }
  end

  context "different filter - but both including distinct" do
    let(:student_distinct_filter) { "DISTINCT" }
    let(:instructor_distinct_filter) { "DISTINCTROW" }

    it { expect(subject.rounded_grade).to eq(0.5) }
  end
end
