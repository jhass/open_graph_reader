# 0.9.1

* Breaking: Renamed synthesize_image_url setting to synthesize_full_image_url
* Add new synthesize_image_content setting: With this setting set to true,
  return og:image:url as the og:image content when og:image is absent.
* Fix returning og:image:url of og:image is absent

# 0.8.0

* Drop Ruby 2.5, 2.6, 2.7, 3.0 support
* Support Ruby 3.1, 3.2, 3.3, 3.4
* Switch from loading faraday_middleware to individual gems (faraday-follow_redirects)
* Fix bug when parsing object hierarchies where child nodes come before parent nodes in document order [#12](https://github.com/jhass/open_graph_reader/issues/12)

# 0.7.2

* Fix bug when trying to parse page without title tag with title synthesization turned on

# 0.7.1

* General project maintenance
* Adhere to Debian Ruby packaging guidelines [#7](https://github.com/jhass/open_graph_reader/pull/7)

# 0.7.0

* Consider documents with no actual og tags but just tags from other namespaces as having no open graph data
* Drop Ruby 2.1, 2.2, 2.3 support
* Support Ruby 2.5, 2.6

# 0.6.2

* Drop Ruby 2.0 support
* Loosen dependencies

# 0.6.1

* Ignore meta tags with no content attribute. [#3](https://github.com/jhass/open_graph_reader/pull/3)

# 0.6.0

* Breaking: Renamed synthesize_url setting to synthesize_full_url
* Breaking: Add new synthesize_url setting with a different meaning: With this setting
  set to true, return the URL the document originated from, if available for
  og:url if it's missing.

# 0.5.0

* Support discarding invalid optional properties instead of failing
  completely.
* Support non ISO8601 datetimes.
* Support URL synthesization from a path for any kind of URL,
  not just images.

# 0.4.0

* With image synthesization turned on, normalize the protocol hack (`//`)
  to https.
* Swallow any exceptions raised by Faraday.
* Set Accept and User-Agent header.

# 0.3.1

* Correct insertion order of Faraday middlewares.

# 0.3.0

* Fix a case of raising undefined property while building the object in
  normal mode.
* Support synthesizing og:title.
* Support absolute image paths.

# 0.2.0

* Normalize case of properties.
* Implement required property and vertical validation.
* Normalize case of og:type.
* Optional support for cookie requiring websites.
* Support disabling required attribute validation.
* Support disabling validating that references are an URL.
* By default the most common errors are ignored now, they can be brought
  back with the new `strict` configuration option.
