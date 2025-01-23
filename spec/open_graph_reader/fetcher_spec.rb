require "spec_helper"

RSpec.describe OpenGraphReader::Fetcher do
  let(:host) { "example.org" }
  let(:uri) { URI("http://#{host}") }
  let(:fetcher) { described_class.new uri }
  let(:good_response) { {status: 200, body: "", headers: {"Content-Type" => "text/html"}} }

  context "with an error during body fetch" do
    before do
      stub_request(:head, host).to_return(good_response)
      stub_request(:get, host).to_raise(Faraday::ConnectionFailed.new("execution expired"))
    end

    describe "#body" do
      it "raises" do
        expect { fetcher.body }.to raise_error OpenGraphReader::NoOpenGraphDataError, /response body/
      end
    end
  end
end
