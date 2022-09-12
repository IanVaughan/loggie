# Loggie [![CircleCI](https://circleci.com/gh/IanVaughan/loggie.svg?style=svg)](https://circleci.com/gh/IanVaughan/loggie) [![Gem Version](https://badge.fury.io/rb/loggie.svg)](https://badge.fury.io/rb/loggie)

Loggie is a log aggregator to query your logs that have been pushed to third party log hosting providers.

It uses adapters to query different providers, and currently supports the following :

* Logentries

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'loggie'
```

And then execute:

    bundle

Or install it yourself as:

    gem install loggie

## Configuring

```ruby
Loggie.configure do |config|
  # from https://logentries.com/app/<app>#/user-account/apikey
  config.read_token = 'key'

  # A comma separated list of log file ids
  # From LogEntries logset "KEY: 83cacd7-ad66-4f6d-9171-00dd478gbd11
  # "Use the key with our REST API to query the log."
  config.log_files = ['e20bd6af', 'c83c7cd7', '6fb426fd', '776dfea9']

  # Depending on the size of the underlying dataset of the complexity of the query,
  # a request may not yield a value straight away. In this case this gem will request
  # the results up until this retry count
  config.max_retry = 50

  # Time to sleep before each retry, smaller value will poll more
  # and could get get result quicker, but will eat into rate limit
  # of request count
  config.sleep_before_retry_seconds = 0.5

  # If the log message is JSON parsable, then it will slice off all but
  # the ones listed here. Whole log line is returned otherwise.
  config.default_fields_included = ["keys", "from", "log", "output"]
end
```

## Usage

irb -r ./lib/loggie


```ruby
Loggie.search(query: "foobar") { |progress| puts "#{progress}% there!" }
  => {:timestamp=>Sun, 08 Jan 2017 01:00:58 +0000,
  :message=>
  { "remote_addr"=>"11.11.36.72",
    "version"=>"HTTP/1.1",
    "host"=>"host.com",
    "x_forwared_for"=>"11.11.11.11",
    ...

Loggie.search(query: "service:(shopify-sync-staging OR out-fund-staging) @class:ShopifyRawOrderTransactionsConsumer")

```

Or, use from the command line with:

`loggie foobar`

env is required for command line usage, and can be prefixed to the command, eg:

`READ_TOKEN=abc LOG_FILES=x,y,z loggie foobar`

Or the create a `.loggie` file somewhere in the current path.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To add a new adapter, create the directory in `/lib/loggie/name-of-adapter`.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/IanVaughan/loggie>.

1. Fork it ( <https://github.com/IanVaughan/loggie/fork> )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
