require 'spec_helper'

RSpec.describe "invalid examples" do
  %w(plain error).each do |example|
    describe example do
      it "says there are no tags" do
        expect {
          OpenGraphReader.parse! example_html 'plain'
        }.to raise_error OpenGraphReader::NoOpenGraphDataError, /OpenGraph tags/
      end
    end
  end

  describe "filters/xss-image" do
    it "errors on the invaid URL" do
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
    it "doesn't recognize the old elements" do
      expect {
        OpenGraphReader.parse! example_html 'errors/geo'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Undefined property/
    end
  end

  describe "errors/type" do
    it "doesn't handle the unkown type" do
      expect {
        OpenGraphReader.parse! example_html 'errors/type'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Undefined type/
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
