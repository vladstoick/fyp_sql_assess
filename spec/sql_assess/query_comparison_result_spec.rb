require "spec_helper"

RSpec.describe SqlAssess::QueryComparisonResult do
  subject { described_class.new(success: success, attributes: attributes) }

  let(:attributes) do
    {
      columns: {
        student_columns: ['a', 'd', 'g', 'e'],
        instructor_columns: ['a', 'b', 'c', 'd', 'e']
      },
      order_by: {
        student_order_by: ['a ASC', 'b DESC', 'g', 'f'],
        instructor_order_by: ['a ASC', 'b DESC', 'f']
      },
      where: {
        student_where: ["a > 1", "b > 2"],
        instructor_where: ["a > 1", "c > 3"]
      },
      distinct_filter: {
        student_distinct_filter: "ALL",
        instructor_distinct_filter: "ALL"
      },
      limit: {
        student_limit: { "limit": 1, "offset": 1 },
        instructor_limit: { "limit": 1, "offset": 1 }
      },
    }
  end

  context "#grade" do
    context "with success true" do
      let(:success) { true }

      it { expect(subject.grade).to eq(100) }
    end

    context "with success false" do
      let(:success) { false }

      it "returns a number" do
        expect(subject.grade).to be_a(BigDecimal)
      end
    end
  end

  context "#attributes_grade" do
    let(:success) { false }

    it "returns a hash" do
      expect(subject.attributes_grade).to match({
        columns: an_instance_of(BigDecimal),
        order_by: an_instance_of(BigDecimal),
        where: an_instance_of(BigDecimal),
        distinct_filter: an_instance_of(BigDecimal),
        limit: an_instance_of(BigDecimal),
      })
    end
  end
end
