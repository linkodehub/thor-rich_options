# Thor::RichOptions

[![Gem Version](https://badge.fury.io/rb/thor-rich_options.svg)](https://badge.fury.io/rb/thor-rich_options)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/thor/rich_options`. To experiment with that code, run `bin/console` for an interactive prompt.

This gem provides new features for option of [thor](https://github.com/erikhuda/thor) library by `exclusive` and `at_least_one` method.
These features have already [PR](https://github.com/erikhuda/thor/pull/483).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'thor-rich_options'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install thor-rich_options

## Usage

First you need to require out library instead of `thor`

```ruby
require 'thor/rich_options'
```

Then you can add two features for `exclusive` options and required `at_least_one` option for thor
For exclusive options,

```ruby
exclusive do
  option :one
  option :two
end
```

You cann't give option `--one` and `--two` at the same time.
If you give wrong options, it shows an error as follows:

```
Found exclusive options '--one`, `--two`
```

For required at least one option:

```ruby
at_least_one do
  option :three
  option :four
end
```

You must give at least one option `--three` or `--four`.
This error message:
```
Not found at least one of required options `--three`, `--four`
```

`#class_exclusive` and `#class_at_least_one` methods can be used for `class_option`.
If `#excusive`/`#class_exclusive` or `#at_least_one`/`#class_at_least_one` are defined, the help command show you the relation of options after the`Options:` list as follows:

```
Exclusive Options:
  --one   --two

Required At Least One:
  --three  --four
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/thor-rich_options. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

