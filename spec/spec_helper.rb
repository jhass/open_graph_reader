require "webmock/rspec"

require "open_graph_reader"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  config.warnings = true if ENV["TRAVIS"]

  config.default_formatter = "doc" if config.files_to_run.one?

  config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed

  config.after(:each) do
    OpenGraphReader.config.reset_to_defaults!
  end
end

def example_html example
  fixture_html "examples/#{example}"
end

def fixture_html fixture
  File.read File.expand_path("./fixtures/#{fixture}.html", __dir__)
end
