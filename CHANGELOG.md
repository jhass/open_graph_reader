# 0.6.0

* Renamed synthesize_url setting to synthesize_full_url

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
