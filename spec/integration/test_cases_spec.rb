require "spec_helper"

RSpec.describe "test cases" do
  describe "image_alt_before_image" do
    it "parses" do
      expect {
        OpenGraphReader.parse! fixture_html "test_cases/image_alt_before_image"
      }.not_to raise_error
    end

    it "returns the data" do
      object = OpenGraphReader.parse!(fixture_html("test_cases/image_alt_before_image"))
      expect(object.og.image.content).to eq "https://example.com/example.png"
      expect(object.og.image.alt).to eq "image:alt"
    end
  end
end
