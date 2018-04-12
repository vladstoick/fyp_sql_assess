require "spec_helper"

RSpec.describe SqlAssess::QueryComparisonResult do
  subject { described_class.new(success: success, attributes: attributes) }

  let(:attributes) do
    SqlAssess::QueryAttributeExtractor.new.extract(
      (
        <<-SQL.squish
          SELECT table1.a
          FROM table1
        SQL
      ), (
        <<-SQL.squish
          SELECT table1.a
          FROM table1
        SQL
      )
    )
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
        tables: an_instance_of(BigDecimal),
        group: an_instance_of(BigDecimal),
        having: an_instance_of(BigDecimal),
      })
    end
  end

  context "#message" do
    context "with success = true" do
      let(:success) { true }

      it { expect(subject.message).to eq("Congratulations! Your solution is correct") }
    end

    context "with success = false" do
      let(:success) { false }

      before do
        allow_any_instance_of(described_class).to receive(:first_wrong_component).and_return(component)
      end

      context "with columns first_wrong_attribute" do
        let(:component) { :columns }

        it { expect(subject.message).to eq("Your query is not correct. Check what columns you are selecting.") }
      end

      context "with tables first_wrong_attribute" do
        let(:component) { :tables }

        it { expect(subject.message).to eq("Your query is not correct. Are you sure you are selecting the right tables?") }
      end

      context "with order_by first_wrong_attribute" do
        let(:component) { :order_by }

        it { expect(subject.message).to eq("Your query is not correct. Are you ordering the rows correctly?") }
      end

      context "with where first_wrong_attribute" do
        let(:component) { :where }

        it { expect(subject.message).to eq("Your query is not correct. Looks like you are selecting the right columns, but you are not selecting only the correct rows.") }
      end

      context "with distinct_filter first_wrong_attribute" do
        let(:component) { :distinct_filter }

        it { expect(subject.message).to eq("Your query is not correct. What about duplicates? What does the exercise say?") }
      end

      context "with limit first_wrong_attribute" do
        let(:component) { :limit }

        it { expect(subject.message).to eq("Your query is not correct. Are you selecting the correct number of rows?") }
      end

      context "with group first_wrong_attribute" do
        let(:component) { :group }

        it { expect(subject.message).to eq("Your query is not correct. Are you grouping by the correct columns?") }
      end
    end
  end
end
