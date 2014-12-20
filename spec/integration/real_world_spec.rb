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

  describe "image_path_2" do
     it "does not parse" do
      expect {
        OpenGraphReader.parse! fixture_html 'real_world/image_path_2'
      }.to raise_error OpenGraphReader::InvalidObjectError, /does not start with/
    end

    it "parses with image paths turned on" do
      OpenGraphReader.config.synthesize_image_url = true

      object = OpenGraphReader.parse! fixture_html('real_world/image_path_2'), 'http://motherboard.vice.com/de/read/forscher-kreieren-ein-material-das-fast-so-dunkel-ist-wie-ein-schwarzes-loch?trk_source=popular'

      expect(object.og.type).to      eq "article"
      expect(object.og.title).to     eq "Forscher kreieren ein Material, das fast so dunkel ist wie ein schwarzes Loch"
      expect(object.og.site_name).to eq "Motherboard"
      expect(object.og.image.url).to eq "https://motherboard-images.vice.com/content-images/article/13701/1405417621515809.JPG?crop=0.75xw:1xh;*,*&resize=500:*&output-format=jpeg&output-quality=90"
      expect(object.og.url).to       eq "http://motherboard.vice.com/de/read/forscher-kreieren-ein-material-das-fast-so-dunkel-ist-wie-ein-schwarzes-loch"
    end
  end

  describe "invalid_article_author" do
    it "does not parse" do
      expect {
        OpenGraphReader.parse! fixture_html 'real_world/invalid_article_author'
      }.to raise_error OpenGraphReader::InvalidObjectError, /does not start with/
    end

    it "ignores the attribute with discarding invalid optional attributes enabled" do
      OpenGraphReader.config.discard_invalid_optional_properties = true

      object = OpenGraphReader.parse! fixture_html 'real_world/invalid_article_author'


      expect(object.article.author).to be_nil
      expect(object.article.section).to eq "blog/engineering"
      expect(object.article.published_time).to eq DateTime.iso8601 "2014-12-18T21:16:27+00:00"
      expect(object.og.site_name).to eq "GitHub"
      expect(object.og.type).to eq "article"
      expect(object.og.image.url).to eq "https://github.com/apple-touch-icon-144.png"
      expect(object.og.title).to eq "Vulnerability announced: update your Git clients"
      expect(object.og.url).to eq "https://github.com/blog/1938-vulnerability-announced-update-your-git-clients"
      expect(object.og.description).to eq <<-DESCRIPTION.chomp
A critical Git security vulnerability has been announced today, affecting all versions of the official Git client and all related software that interacts with Git repositories, including GitHub for Windows and GitHub for Mac. Because this is a client-side only vulnerability, github.com and GitHub Enterprise are not directly affected.

The vulnerability concerns Git and Git-compatible clients that access Git repositories in a case-insensitive or case-normalizing filesystem. An attacker can craft a malicious Git tree that will cause Git to overwrite its own .git/config file when cloning or checking out a repository, leading to arbitrary command execution in the client machine. Git clients running on OS X (HFS+) or any version of Microsoft Windows (NTFS, FAT) are exploitable through this vulnerability. Linux clients are not affected if they run in a case-sensitive filesystem.

We strongly encourage all users of GitHub and GitHub Enterprise to update their Git clients as soon as possible, and to be particularly careful when cloning or accessing Git repositories hosted on unsafe or untrusted hosts.

Repositories hosted on github.com cannot contain any of the malicious trees that trigger the vulnerability because we now verify and block these trees on push. We have also completed an automated scan of all existing content on github.com to look for malicious content that might have been pushed to our site before this vulnerability was discovered. This work is an extension of the data-quality checks we have always performed on repositories pushed to our servers to protect our users against malformed or malicious Git data.

Updated versions of GitHub for Windows and GitHub for Mac are available for immediate download, and both contain the security fix on the Desktop application itself and on the bundled version of the Git command-line client.

In addition, the following updated versions of Git address this vulnerability:


The Git core team has announced maintenance releases for all current versions of Git (v1.8.5.6, v1.9.5, v2.0.5, v2.1.4, and v2.2.1).
Git for Windows (also known as MSysGit) has released maintenance version 1.9.5.
The two major Git libraries, libgit2 and JGit, have released maintenance versions with the fix. Third party software using these libraries is strongly encouraged to update.


More details on the vulnerability can be found in the official Git mailing list announcement and on the git-blame blog.
DESCRIPTION
    end
  end
end
