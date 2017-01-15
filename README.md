# Loggie

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'loggie'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install loggie

## Usage

```ruby
Loggie.search(query: "foobar")
  => {:timestamp=>Sun, 08 Jan 2017 01:00:58 +0000,
  :message=>
  { "remote_addr"=>"11.11.36.72",
    "version"=>"HTTP/1.1",
    "host"=>"host.com",
    "x_forwared_for"=>"11.11.11.11",
    ...

```

Or, use from the command line with:

`loggie foobar`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/IanVaughan/loggie.

1. Fork it ( https://github.com/IanVaughan/loggie/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
