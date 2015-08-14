require "spec_helper"

RSpec.describe OpenGraphReader::Fetcher do
  let(:uri) { URI("http://example.org") }
  let(:fetcher) { described_class.new uri }
  let(:good_response) { {status: 200, body: "", headers: {"Content-Type" => "text/html"}} }

  context "error during body fetch" do
    before do
      stub_request(:head, uri).to_return(good_response)
      stub_request(:get, uri).to_raise(Faraday::ConnectionFailed.new("execution expired"))
    end

    describe "#body" do
      it "raises" do
        expect { fetcher.body }.to raise_error OpenGraphReader::NoOpenGraphDataError, /response body/
      end
    end
  end
end
