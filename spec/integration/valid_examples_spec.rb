require "spec_helper"

RSpec.describe "valid examples" do
  %w(
    article-offset
    article-utc
    audio-array
    audio-url
    audio
    book-isbn10
    book
    canadian
    image-array
    image-toosmall
    image-url
    image
    index
    nomedia
    profile
    required
    video-array
    video-movie
    video
  ).each do |example|
    describe example do
      it "parses" do
        expect {
          OpenGraphReader.parse! example_html example
        }.to_not raise_error
      end
    end
  end

  describe "article" do
    let(:object) { OpenGraphReader.parse! example_html "article" }

    it "parses" do
      expect {
        object
      }.to_not raise_error
    end

    it "allows access to the first tag" do
      expect(object.article.tag).to eq "Watergate"
    end

    it "assigns correctly" do
      expect(object.og.title).to eq "5 Held in Plot to Bug Office"
      expect(object.og.site_name).to eq "Open Graph protocol examples"
      expect(object.og.type).to eq "article"
      expect(object.og.locale.to_s).to eq "en_US"
      expect(object.og.url).to eq "http://examples.opengraphprotocol.us/article.html"
      expect(object.og.image.content).to eq "http://examples.opengraphprotocol.us/media/images/50.png"
      expect(object.og.image.url).to eq "https://d72cgtgi6hvvl.cloudfront.net/media/images/50.png"
      expect(object.og.image.secure_url).to eq "https://d72cgtgi6hvvl.cloudfront.net/media/images/50.png"
      expect(object.og.image.width).to eq 50
      expect(object.og.image.height).to eq 50
      expect(object.og.image.type).to eq "image/png"
      expect(object.article.published_time).to eq DateTime.new(1972, 6, 18)
      expect(object.article.author.content).to eq "http://examples.opengraphprotocol.us/profile.html"
      expect(object.article.section).to eq "Front page"
      expect(object.article.tag).to eq "Watergate"
      expect(object.article.tags).to eq ["Watergate"]
    end
  end

  # Examples say this is invalid, but http://ogp.me defines isbn it as string,
  # so anything goes
  describe "errors/book" do
    it "parses" do
      expect {
        OpenGraphReader.parse! example_html "errors/book"
      }.to_not raise_error
    end
  end
end
