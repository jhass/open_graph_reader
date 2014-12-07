require 'spec_helper'

RSpec.describe "invalid examples" do
  describe "plain" do
    it "says there are no tags" do
      expect {
        OpenGraphReader.parse! example_html 'plain'
      }.to raise_error OpenGraphReader::NoOpenGraphDataError, /OpenGraph tags/
    end

    it "says there are no tags with title synthesization turend on" do
      OpenGraphReader.config.synthesize_title = true

      expect {
        OpenGraphReader.parse! example_html 'plain'
      }.to raise_error OpenGraphReader::NoOpenGraphDataError, /OpenGraph tags/
    end
  end

  describe "min" do
    it "has missing required properties" do
      expect {
        OpenGraphReader.parse! example_html 'min'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Missing required/
    end

    it "returns what's there if required property validation is disabled" do
      OpenGraphReader.config.validate_required = false
      object = OpenGraphReader.parse! example_html 'min'
      expect(object.og.site_name).to   eq "Open Graph protocol examples"
      expect(object.og.description).to eq "Content not on page"
    end
  end

  describe "filters/xss-image" do
    it "errors on the invaid URL in strict mode" do
      expect {
        OpenGraphReader.parse! example_html 'filters/xss-image'
      }.to raise_error OpenGraphReader::InvalidObjectError, /does not start with http/
    end
  end

  describe "errors/article-date" do
    it "has an incorrectly formatted date" do
      expect {
        OpenGraphReader.parse! example_html 'errors/article-date'
      }.to raise_error OpenGraphReader::InvalidObjectError, /ISO8601 datetime expected/
    end
  end

  describe "errors/book-author" do
    it "doesn't have a profile object as author" do
      expect {
        OpenGraphReader.parse! example_html 'errors/book-author'
      }.to raise_error OpenGraphReader::InvalidObjectError, /does not start with http/
    end
  end

  describe "errors/gender" do
    it "doesn't have a valid gender" do
      expect {
        OpenGraphReader.parse! example_html 'errors/gender'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Expected one of/
    end
  end

  describe "errors/geo" do
    it "doesn't recognize the old elements in strict mode" do
      OpenGraphReader.config.strict = true

      expect {
        OpenGraphReader.parse! example_html 'errors/geo'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Undefined property/
    end

    it "parses in default mode" do
      object = OpenGraphReader.parse! example_html 'errors/geo'

      expect(object.og.type).to      eq "website"
      expect(object.og.title).to     eq "Open Graph protocol 1.0 location data"
      expect(object.og.url).to       eq "http://examples.opengraphprotocol.us/errors/geo.html"
      expect(object.og.image.url).to eq "http://examples.opengraphprotocol.us/media/images/50.png"
    end
  end

  describe "errors/type" do
    it "doesn't handle the unknown type in strict mode" do
      OpenGraphReader.config.strict = true

      expect {
        OpenGraphReader.parse! example_html 'errors/type'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Undefined type/
    end

    it "parses the known properties" do
      object = OpenGraphReader.parse! example_html 'errors/type'

      expect(object.og.type).to      eq "fubar"
      expect(object.og.title).to     eq "Undefined global type"
      expect(object.og.url).to       eq "http://examples.opengraphprotocol.us/errors/type.html"
      expect(object.og.image.url).to eq "http://examples.opengraphprotocol.us/media/images/50.png"
    end
  end

  describe "errors/video-duration" do
    it "only accepts integers" do
      expect {
        OpenGraphReader.parse! example_html 'errors/video-duration'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Integer expected/
    end
  end
end
