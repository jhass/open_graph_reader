require 'spec_helper'

RSpec.describe "real world examples" do
  describe "mixed_case_properties" do
    it "parses" do
      expect {
        OpenGraphReader.parse! fixture_html 'real_world/mixed_case_properties'
      }.to_not raise_error
    end

    it "assigns the right attributes" do
      object = OpenGraphReader.parse fixture_html 'real_world/mixed_case_properties'

      expect(object.og.title).to       eq "Eine Million Unterschriften gegen TTIP"
      expect(object.og.type).to        eq "website"
      expect(object.og.locale.to_s).to eq "de_DE"
      expect(object.og.url).to         eq "http://www.heise.de/tp/artikel/43/43516/"
      expect(object.og.site_name).to   eq "Telepolis"
      expect(object.og.image.url).to   eq "http://www.heise.de/tp/artikel/43/43516/43516_1.jpg"
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

  describe "mixed_case_type" do
    it "parses" do
      expect {
        OpenGraphReader.parse! fixture_html 'real_world/mixed_case_type'
      }.to_not raise_error
    end
  end

  describe "not_a_reference" do
    it "does not parse" do
      expect {
        OpenGraphReader.parse! fixture_html 'real_world/not_a_reference'
      }.to raise_error OpenGraphReader::InvalidObjectError, /does not start with/
    end

    it "parses with reference validation turned of" do
      OpenGraphReader.config.validate_references = false
      object = OpenGraphReader.parse! fixture_html 'real_world/not_a_reference'

      expect(object.og.title).to            eq "Emergency call system for all new cars by 2018"
      expect(object.og.type).to             eq "article"
      expect(object.og.description).to      eq "The European Parliament and EU member states have agreed that new cars must be fitted with an automated system to alert emergency services in event of a crash."
      expect(object.og.site_name).to        eq "BBC News"
      expect(object.og.url).to              eq "http://www.bbc.co.uk/news/technology-30337272"
      expect(object.og.image.url).to        eq "http://news.bbcimg.co.uk/media/images/79520000/jpg/_79520623_79519885.jpg"
      expect(object.article.author.to_s).to eq "BBC News"
      expect(object.article.section).to     eq "Technology"
    end
  end

  describe "unknown_type" do
    it "parses" do
      object = OpenGraphReader.parse! fixture_html 'real_world/unknown_type'

      expect(object.og.url).to         eq "http://www.instructables.com/id/Building-the-Open-Knit-machine/"
      expect(object.og.title).to       eq "Building the OpenKnit machine"
      expect(object.og.image.url).to   eq "http://cdn.instructables.com/FI2/D7XW/I2XTQWFE/FI2D7XWI2XTQWFE.RECTANGLE1.jpg"
      expect(object.og.description).to eq "The OpenKnit machine is an open-source, low cost, digital fabrication tool developed by Gerard Rubio.  The machine affords the user the opportunity to..."
    end

    it "does not parse in strict mode" do
      OpenGraphReader.config.strict = true

      expect {
        OpenGraphReader.parse! fixture_html 'real_world/unknown_type'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Undefined type/
    end
  end

  describe "undefined_property" do
    it "parses (1)" do
      object = OpenGraphReader.parse! fixture_html 'real_world/undefined_property'

      expect(object.og.locale.to_s).to eq "es_ES"
      expect(object.og.type).to        eq "article"
      expect(object.og.title).to       eq "Profesores y campesinos amarran a infiltrados en marcha"
      expect(object.og.description).to eq "Regeneración, 6 de diciembre de 2014.-Durante la marcha que realizan profesores y organizaciones campesinas sobre avenida Paseo de la Reforma, maestros de la Coordinadora Estatal de Trabajadores de la Educación en Guerrero (CETEG) ubicaron a 12 jóvenes como “infiltrados”, a quienes amarraron de las manos en una cadena humana para evitar que marchen con ellos, informó El …"
      expect(object.og.url).to         eq "http://regeneracion.mx/sociedad/profesores-y-campesinos-amarran-a-infiltrados-en-marcha/"
      expect(object.og.site_name).to   eq "Regeneración"
      expect(object.og.image.url).to   eq "http://regeneracion.mx/wp-content/uploads/2014/12/Infiltrados.jpg"
    end

    it "does not parse in strict mode (1)" do
      OpenGraphReader.config.strict = true

      expect {
        OpenGraphReader.parse! fixture_html 'real_world/undefined_property'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Undefined property/
    end

    it "parses (2)" do
      object = OpenGraphReader.parse! fixture_html 'real_world/undefined_property_2'


      expect(object.og.title).to            eq "Emergency call system for all new cars by 2018"
      expect(object.og.type).to             eq "article"
      expect(object.og.description).to      eq "The European Parliament and EU member states have agreed that new cars must be fitted with an automated system to alert emergency services in event of a crash."
      expect(object.og.site_name).to        eq "BBC News"
      expect(object.og.url).to              eq "http://www.bbc.co.uk/news/technology-30337272"
      expect(object.og.image.url).to        eq "http://news.bbcimg.co.uk/media/images/79520000/jpg/_79520623_79519885.jpg"
    end

    it "does not parse in strict mode (2)" do
      OpenGraphReader.config.strict = true

      expect {
        OpenGraphReader.parse! fixture_html 'real_world/undefined_property_2'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Undefined property/
    end
  end

  describe "unknown_namespace" do
    it "parses" do
      object = OpenGraphReader.parse! fixture_html 'real_world/unknown_namespace'

      expect(object.og.url).to         eq "http://www.instructables.com/id/Building-the-Open-Knit-machine/"
      expect(object.og.title).to       eq "Building the OpenKnit machine"
      expect(object.og.image.url).to   eq "http://cdn.instructables.com/FI2/D7XW/I2XTQWFE/FI2D7XWI2XTQWFE.RECTANGLE1.jpg"
      expect(object.og.description).to eq "The OpenKnit machine is an open-source, low cost, digital fabrication tool developed by Gerard Rubio.  The machine affords the user the opportunity to..."
    end

    it "does not parse in strict mode" do
      OpenGraphReader.config.strict = true

      expect {
        OpenGraphReader.parse! fixture_html 'real_world/unknown_namespace'
      }.to raise_error OpenGraphReader::InvalidObjectError, /is not a registered namespace/
    end
  end


  describe "missing_title" do
    it "does not parse" do
      expect {
        OpenGraphReader.parse! fixture_html 'real_world/missing_title'
      }.to raise_error OpenGraphReader::InvalidObjectError, /Missing required/
    end

    it "does parse when synthesizing titles" do
      OpenGraphReader.config.synthesize_title = true

      object = OpenGraphReader.parse! fixture_html 'real_world/missing_title'

      expect(object.og.type).to      eq "website"
      expect(object.og.title).to     eq "Ultra Conservative Christian Lady Goes To Museum, Tries To Debunk Evolution, Fails Beyond Miserably | Geekologie"
      expect(object.og.image.url).to eq "http://geekologie.com/assets_c/2014/11/crazy-lady-goes-to-the-museum-thumb-640x389-29314.jpg"
    end
  end

  describe "image_path" do
    it "does not parse" do
      expect {
        OpenGraphReader.parse! fixture_html 'real_world/image_path'
      }.to raise_error OpenGraphReader::InvalidObjectError, /does not start with/
    end

    it "parses with image paths turned on" do
      OpenGraphReader.config.synthesize_image_url = true

      object = OpenGraphReader.parse! fixture_html('real_world/image_path'), 'http://fritzing.org/download/'

      expect(object.og.title).to     eq "Fritzing"
      expect(object.og.type).to      eq "website"
      expect(object.og.image.url).to eq "http://fritzing.org/static/img/fritzing.png"
      expect(object.og.url).to       eq "http://fritzing.org/"
    end
  end
end
