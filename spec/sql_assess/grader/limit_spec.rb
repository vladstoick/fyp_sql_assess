require "spec_helper"

RSpec.describe SqlAssess::Grader::Limit do
  subject do
    described_class.new(
      student_attributes: student_limit,
      instructor_attributes: instructor_limit
    )
  end

  context "same limit and offsert" do
    let(:student_limit) { { "limit": 1, "offset": 0 } }
    let(:instructor_limit) { { "limit": 1, "offset": 0 } }

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "same limit but different offset" do
    let(:student_limit) { { "limit": 1, "offset": 1 } }
    let(:instructor_limit) { { "limit": 1, "offset": 0 } }

    it { expect(subject.rounded_grade).to eq(0.5) }
  end

  context "different limit but same offset" do
    let(:student_limit) { { "limit": 2, "offset": 0 } }
    let(:instructor_limit) { { "limit": 1, "offset": 0 } }

    it { expect(subject.rounded_grade).to eq(0.5) }
  end

  context "different limit and offset" do
    let(:student_limit) { { "limit": 2, "offset": 0 } }
    let(:instructor_limit) { { "limit": 1, "offset": 2 } }

    it { expect(subject.rounded_grade).to eq(0) }
  end
end
