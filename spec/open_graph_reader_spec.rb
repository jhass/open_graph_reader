require "spec_helper"

RSpec.describe OpenGraphReader do
  let(:invalid_object) { "<head><meta property='og:type' content='foobar' /></head>" }

  describe "::fetch!" do
    it "raises if there's no html" do
      allow(OpenGraphReader::Fetcher).to receive(:new).and_return(double(html?: false))

      expect {
        described_class.fetch! "http://example.org"
      }.to raise_error OpenGraphReader::NoOpenGraphDataError
    end

    it "raises if there are no tags" do
      fetcher = double(html?: true, url: "http://example.org", body: "")
      allow(OpenGraphReader::Fetcher).to receive(:new).and_return(fetcher)
      allow(OpenGraphReader::Parser).to receive(:new).and_return(double(any_tags?: false))
      expect {
        described_class.fetch! "http://example.org"
      }.to raise_error OpenGraphReader::NoOpenGraphDataError
    end

    it "raises if there's an invalid object" do
      fetcher = double(html?: true, url: "http://example.org", body: invalid_object)
      allow(OpenGraphReader::Fetcher).to receive(:new).and_return(fetcher)

      expect {
        described_class.fetch! "http://example.org"
      }.to raise_error OpenGraphReader::InvalidObjectError
    end
  end

  describe "::fetch" do
    it "does not raise if there's no html" do
      allow(OpenGraphReader::Fetcher).to receive(:new).and_return(double(html?: false))

      expect {
        described_class.fetch "http://example.org"
      }.not_to raise_error
    end

    it "does not raise if there are no tags" do
      fetcher = double(html?: true, url: "http://example.org", body: "")
      allow(OpenGraphReader::Fetcher).to receive(:new).and_return(fetcher)
      allow(OpenGraphReader::Parser).to receive(:new).and_return(double(any_tags?: false))

      expect {
        described_class.fetch "http://example.org"
      }.not_to raise_error
    end

    it "does not raise if there's an invalid object" do
      fetcher = double(html?: true, url: "http://example.org", body: invalid_object)
      allow(OpenGraphReader::Fetcher).to receive(:new).and_return(fetcher)

      expect {
        described_class.fetch "http://example.org"
      }.not_to raise_error
    end
  end

  describe "::parse!" do
    it "raises if there are no tags" do
      allow(OpenGraphReader::Parser).to receive(:new).and_return(double(any_tags?: false))

      expect {
        described_class.parse! ""
      }.to raise_error OpenGraphReader::NoOpenGraphDataError
    end

    it "raises if there's an invalid object" do
      expect {
        described_class.parse! invalid_object
      }.to raise_error OpenGraphReader::InvalidObjectError
    end
  end

  describe "::parse" do
    it "does not raise if there are no tags" do
      allow(OpenGraphReader::Parser).to receive(:new).and_return(double(any_tags?: false))

      expect {
        described_class.parse ""
      }.not_to raise_error
    end

    it "does not raise if there's an invalid object" do
      expect {
        described_class.parse invalid_object
      }.not_to raise_error
    end
  end
end
