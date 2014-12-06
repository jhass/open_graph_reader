require 'spec_helper'

RSpec.describe "real world examples" do
  describe "mixed_case" do
    it "parses" do
      expect {
        OpenGraphReader.parse! fixture_html 'real_world/mixed_case'
      }.to_not raise_error
    end

    it "assigns the right attributes" do
      object = OpenGraphReader.parse fixture_html 'real_world/mixed_case'

      expect(object.og.title).to eq "Eine Million Unterschriften gegen TTIP"
      expect(object.og.type).to eq "website"
      expect(object.og.locale.to_s).to eq "de_DE"
      expect(object.og.url).to eq "http://www.heise.de/tp/artikel/43/43516/"
      expect(object.og.site_name).to eq "Telepolis"
      expect(object.og.image.url).to eq "http://www.heise.de/tp/artikel/43/43516/43516_1.jpg"
      expect(object.og.description).to eq "Ungenehmigte Bürgerinitiative will das Paket EU-Kommissionschef Juncker zum Geburtstag schenken"
    end
  end

  describe "missing_image" do
    it "does not parse" do
      expect {
        OpenGraphReader.parse! fixture_html 'real_world/missing_image'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Missing required/
    end
  end
end
