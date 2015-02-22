require "open_graph_reader/object"

module OpenGraphReader
  # @see http://ogp.me/#metadata
  class Og
    include Object

    namespace :og

    # @!macro property
    # @return [String]
    string :type,  required: true, downcase: true, default: "website"

    # @!macro property
    # @return [String]
    string :title, required: true

    # @!attribute [r] images
    #   @return [Array<Image>]
    # @!macro property
    # @return [Image]
    url :image, required: true, collection: true

    # @!macro property
    # @return [String, nil]
    url :url

    # @!macro property
    # @return [Audio, nil]
    url :audio

    # @!macro property
    # @return [String, nil]
    string :description

    # @!macro property
    # @return [String]
    enum :determiner, ["", "a", "an", "the", "auto"], default: ""

    # @!macro property
    # @return [Locale, nil]
    string :locale

    # @!macro property
    # @return [String, nil]
    string :site_name

    # @!macro property
    # @return [Video, nil]
    url :video

    # @see http://ogp.me/#structured
    class Image
      include Object

      namespace :og, :image
      content :url, image: true

      url :url

      # @!macro property
      # @return [String, nil]
      url :secure_url

      # @!macro property
      # @return [String, nil]
      string :type

      # @!macro property
      # @return [Integer, nil]
      integer :width

      # @!macro property
      # @return [Integer, nil]
      integer :height

      # @return [String, nil]
      def url
        secure_url || properties[:url] || content
      end
    end

    # @see http://ogp.me/#structured
    class Audio
      include Object

      namespace :og, :audio
      content :url

      # This property is not listed on http://ogp.me, but commonly found
      url :url

      # @!macro property
      # @return [String, nil]
      url :secure_url

      # @!macro property
      # @return [String, nil]
      string :type

      # @return [String, nil]
      def url
        secure_url || properties[:url] || content
      end
    end

    # @see http://ogp.me/#metadata
    class Locale
      include Object

      namespace :og, :locale
      content :string

      # @!attribute [r] alternates
      #   @return [Array<String>]
      # @!macro property
      # @return [String, nil]
      string :alternate, collection: true
    end

    # @see http://ogp.me/#structured
    class Video
      include Object

      namespace :og, :video
      content :url

      # @!macro property
      # @return [String, nil]
      url :secure_url

      # @!macro property
      # @return [String, nil]
      string :type

      # @!macro property
      # @return [Integer, nil]
      integer :width

      # @!macro property
      # @return [Integer, nil]
      integer :height

      # @return [String, nil]
      def url
        secure_url || content
      end
    end
  end

  # @see http://ogp.me/#type_profile
  class Profile
    include Object

    namespace :profile
    content :url

    # @!macro property
    # @return [String, nil]
    string :first_name

    # @!macro property
    # @return [String, nil]
    string :last_name

    # @!macro property
    # @return [String, nil]
    string :username

    # @!macro property
    # @return [String, nil]
    enum :gender, %w(male female)

    # @!macro property
    # @return [String, nil]
    # This one only exists because video had to define a video:actor:role,
    # yay for designing a protocol with implementations in mind
    string :role
  end

  # @see http://ogp.me/#type_article
  class Article
    include Object

    namespace :article

    # @!macro property
    # @return [DateTime, nil]
    datetime :published_time

    # @!macro property
    # @return [DateTime, nil]
    datetime :modified_time

    # @!macro property
    # @return [DateTime, nil]
    datetime :expiration_time

    # @todo This one is a reference to another OpenGraph object. Support fetching it?
    # @!attribute [r] authors
    #   @return [Array<Profile>]
    # @!macro property
    # @return [Profile, nil]
    url :author, collection: true, to: Profile

    # @!macro property
    # @return [String, nil]
    string :section

    # @!attribute [r] tags
    #   @return [Array<String>]
    # @!macro property
    # @return [String, nil]
    string :tag, collection: true
  end

  # @see http://ogp.me/#type_video
  class Video
    include Object

    namespace :video

    # @!attribute [r] actors
    #  @return [Array<Profile>]
    # @!macro property
    # @return [Profile, nil]
    url :actor,    to: Profile, verticals: %w(movie episode tv_show other), collection: true

    # @!attribute [r] directors
    #  @return [Array<Profile>]
    # @!macro property
    # @return [Profile, nil]
    url :director, to: Profile, verticals: %w(movie episode tv_show other), collection: true

    # @!attribute [r] writers
    #  @return [Array<Profile>]
    # @!macro property
    # @return [Profile, nil]
    url :writer,   to: Profile, verticals: %w(movie episode tv_show other), collection: true

    # @!macro property
    # @return [Integer, nil]
    integer :duration,          verticals: %w(movie episode tv_show other)

    # @!macro property
    # @return [DateTime, nil]
    datetime :release_date,     verticals: %w(movie episode tv_show other)

    # @!attribute [r] tags
    #   @return [Array<String>]
    # @!macro property
    # @return [String, nil]
    string :tag,                verticals: %w(movie episode tv_show other), collection: true

    # @todo validate that target vertical is video.tv_show ?
    # @!macro property
    # @return [Sring, nil]
    url :series,   to: Video,   verticals: %w(episode)
  end

  # @see http://ogp.me/#type_book
  class Book
    include Object

    namespace :book

    # @todo This one is a reference to another OpenGraph object. Support fetching it?
    # @!attribute [r] authors
    #   @return [Array<Profile>]
    # @!macro property
    # @return [Profile, nil]
    url :author, collection: true, to: Profile

    # @!macro property
    # @return [Sring, nil]
    string :isbn

    # @!macro property
    # @return [DateTime, nil]
    datetime :release_date

    # @!attribute [r] tags
    #   @return [Array<String>]
    # @!macro property
    # @return [String, nil]
    string :tag, collection: true
  end

  # @see http://ogp.me/#type_music
  class Music
    include Object

    namespace :music

    # @!macro property
    # @return [Integer, nil]
    integer :duration, verticals: %w(song)

    # @todo validate that target vertical is music.album/music.song ?
    # @!attribute [r] albums
    #   @return [Array<Music>]
    # @macro property
    # @return [Music, nil]
    url :album, to: Music,      verticals: %w(song),      collection: true

    # @macro property
    # @return [Integer, nil]
    integer :disc,              verticals: %w(song album playlist)

    # @macro property
    # @return [Integer, nil]
    integer :track,             verticals: %w(song album playlist)

    # @!attribute [r] musicians
    #  @return [Array<Profile>]
    # @!macro property
    # @return [Profile, nil]
    url :musician, to: Profile, verticals: %w(song album), collection: true

    # @macro property
    # @return [Music, nil]
    url :song, to: Music,       verticals: %w(album playlist)

    # @macro property
    # @return [DateTime, nil]
    datetime :release_date,     verticals: %w(album)

    # @macro property
    # @return [Profile, nil]
    url :creator, to: Profile,  verticals: %w(playlist radio_station)
  end
end
