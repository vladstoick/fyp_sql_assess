require "spec_helper"

RSpec.describe SqlAssess::Grader::Base do
  context "#levenshtein_distance" do
    it "returns the correct distance for a and empty string" do
      expect(subject.levenshtein_distance("a", "")).to eq(1)
    end

    it "returns the correct distance for a and a" do
      expect(subject.levenshtein_distance("a", "a")).to eq(0)
    end

    it "returns the correct distance for a and b" do
      expect(subject.levenshtein_distance("a", "b")).to eq(1)
    end

    it "returns the correct distance for a and ab" do
      expect(subject.levenshtein_distance("a", "ab")).to eq(1)
    end

    it "returns the correct distance for ab and ab" do
      expect(subject.levenshtein_distance("ab", "ab")).to eq(0)
    end

    it "returns the correct distance for ab and empty string" do
      expect(subject.levenshtein_distance("ab", "")).to eq(2)
    end

    it "returns the correct distance for ab and b" do
      expect(subject.levenshtein_distance("ab", "b")).to eq(1)
    end
  end
end
