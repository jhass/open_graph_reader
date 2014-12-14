# 0.4.0

* With image synthesization turned on, normalize the protocol hack (`//`)
  to https.

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
