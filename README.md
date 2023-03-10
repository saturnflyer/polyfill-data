# Polyfill - Data

Add the Ruby 3.2 [Data](https://docs.ruby-lang.org/en/3.2/Data.html) class to earlier Rubies.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add polyfill-data

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install polyfill-data

Polyfill-Data is cryptographically signed. To be sure the gem you install hasn’t been tampered with:

Add the public key (if you haven’t already) as a trusted certificate

    gem cert --add <(curl -Ls https://raw.github.com/saturnflyer/polyfill-data/main/certs/saturnflyer.pem)

    gem install polyfill-data -P HighSecurity

## Usage

```ruby
require 'polyfill-data'

MyValue = Data.define(:some, :stuff)
a_value = MyValue.new(some: "thing", stuff: "here")
puts a_value.to_h # => { some: "thing", stuff: "here" }

another = a_value.with(stuff: "there")
puts another.eql?(a_value) # => false
puts another.to_h # => { some: "thing", stuff: "there" }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saturnflyer/polyfill-data.
