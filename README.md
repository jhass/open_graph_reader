# OpenGraphReader

A library to fetch and parse OpenGraph properties from an URL or a given string.

## Features

* Strives to be robust and complete.
* Intuitive method based API.
* Supports custom prefixes.
* Validates properties according to their type.

## Anti-features

* Ignores the complete object if anything is invalid.
* Does not fall back to guess the basic attributes from regular tags.
* Only supports the latest OpenGraph protocol as defined at http://ogp.me.
* Properties are defined in code, not by parsing the response at the namespace identifier.


Ruby 2.0 and later are supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'open_graph_reader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install open_graph_reader

## Usage

```ruby
require 'open_graph_reader'

# Returns nil if anything on the object is invalid
object = OpenGraphReader.fetch("http://examples.opengraphprotocol.us/article.html")

# Raises if anything on the object is invalid
object = OpenGraphReader.fetch!("http://examples.opengraphprotocol.us/article.html")

# Read from string
object = OpenGraphReader.parse(html)
object = OpenGraphReader.parse!(html)

# Access by full property name
object.og.title #=> "5 Held in Plot to Bug Office"

# Optional properties can return nil
object.og.description #=> nil

# Supports properties that are objects themselves
object.og.image.to_s    #=> "http://examples.opengraphprotocol.us/media/images/50.png"
object.og.image.content #=> "http://examples.opengraphprotocol.us/media/images/50.png"
object.og.image.url     #=> "https://examples.opengraphprotocol.us/media/images/50.png"
object.og.image.width   #=> 50

# Supports arrays
object.og.images.first == object.og.image #=> true
object.article.tags #=> ["Watergate"]

# Custom namespace
class MyNamespace
  include OpenGraphReader::Object

  namespace :my, :namespace # my:namespace
  string :name, required: true # my:namespace:name
  url :url, default: "http://example.org/my_namespace"
  integer :pages, collection: true
  # See the shipped definitions for more examples
end
```

## Contributing

1. Fork it ( https://github.com/jhass/open_graph_reader/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
