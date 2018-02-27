require "spec_helper"

RSpec.describe SqlAssess::Grader::OrderBy do
  subject do
    described_class.new(
      student_attributes: student_order_by,
      instructor_attributes: instructor_order_by
    )
  end

  context "with empty ordering" do
    let(:student_order_by) { [] }
    let(:instructor_order_by) { [] }

    it { expect(subject.rounded_grade).to eq(1) }
  end

  context "with empty ordering for student while instructor has an ordering" do
    let(:student_order_by) { [] }
    let(:instructor_order_by) { ["id ASC"] }

    it { expect(subject.rounded_grade).to eq(0) }
  end

  context "with empty ordering for instructor while student has an ordering" do
    let(:student_order_by) { ["id ASC"] }
    let(:instructor_order_by) { [] }

    it { expect(subject.rounded_grade).to eq(0) }
  end

  context "with ordering different" do
    let(:student_order_by) { ["id ASC"] }
    let(:instructor_order_by) { ["id2 ASC"] }

    it { expect(subject.rounded_grade).to eq(0) }
  end

  context "with ordering different but with common elements" do
    let(:student_order_by) { ["id ASC"] }
    let(:instructor_order_by) { ["id2 ASC", "id ASC"] }

    it { expect(subject.rounded_grade).to eq(0.67) }
  end

  context "with same column but different order type" do
    let(:student_order_by) { ["id ASC"] }
    let(:instructor_order_by) { ["id DESC"] }

    it { expect(subject.rounded_grade).to eq(0.5) }
  end
end
