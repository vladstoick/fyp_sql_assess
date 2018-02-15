require "spec_helper"

RSpec.describe SqlAssess::QueryComparisonResult do

  subject { described_class.new(success: success, attributes: attributes) }

  context "#grade" do
    context "with success true" do
      let(:success) { true }
      let(:attributes) { double }

      it { expect(subject.grade).to eq(100) }
    end

    context "with success false" do
      let(:success) { false }
      let(:attributes) do
        {
          columns: {
            student_columns: ['a', 'd', 'g', 'e'],
            instructor_columns: ['a', 'b', 'c', 'd', 'e']
          },
          order_by: {
            student_order_by: ['a ASC', 'b DESC', 'g', 'f'],
            instructor_order_by: ['a ASC', 'b DESC', 'f']
          }
        }
      end

      it "returns the percentage of matched columns" do
        expect(subject.grade).to eq(80.0)
      end
    end
  end
end
