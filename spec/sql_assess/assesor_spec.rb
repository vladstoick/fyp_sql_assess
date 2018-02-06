require "spec_helper"

RSpec.describe SqlAssess::Assesor do
  context "#compile" do
    context "without any errors" do
      it "returns the result from data extractor" do
        result = subject.compile(
          create_schema_sql_query: "CREATE TABLE table1 (id integer)",
          instructor_sql_query: "SELECT * from table1",
          seed_sql_query: "INSERT INTO table1 (id) VALUES (1)"
        )

        expect(result).to eq([{
          name: "table1",
          columns: [
            {
              name: "id",
              type: "int(11)"
            },
          ],
          data: [
            "id" => 1
          ],
        }])
      end
    end
  end
end
