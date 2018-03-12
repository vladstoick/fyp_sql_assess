require "spec_helper"

RSpec.describe SqlAssess::QueryComparisonResult do
  subject { described_class.new(success: success, attributes: attributes) }

  let(:attributes) do
    SqlAssess::QueryAttributeExtractor.new(SqlAssess::DatabaseConnection.new).extract(
      (
        <<-SQL.squish
          SELECT a, d, g
          FROM table1 LEFT JOIN table2 on table1.id = table2.id
          WHERE a < 1 AND b < 2
          LIMIT 1 OFFSET 1
        SQL
      ), (
        <<-SQL.squish
          SELECT a, b, c, d
          FROM table1 RIGHT JOIN table2 on table1.id = table2.id
          WHERE a < 1 AND c < 3
          LIMIT 1 OFFSET 1
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
      })
    end
  end
end
