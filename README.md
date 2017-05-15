# EnumerableWeightedSample

This gem provides access to functions that will produce a random sample based on weights calculated from a given block.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'enumerable_weighted_sample'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install enumerable_weighted_sample

## Usage

Provides access to the following functions:
```ruby

  # Produce a weighted random sampling based on the weights calculated from a
  # given block. The weight function must produce positive real numbers.
  # For more, see Ruby Enumerable#max_by and Efraimidis & Spirakis (2005)
  # http://ruby-doc.org/core-2.2.1/Enumerable.html#method-i-max_by
  # http://utopia.duth.gr/~pefraimi/research/data/2007EncOfAlg.pdf
  #
  # Parameters
  #  - count: The number of samples to return. If not provided, will return a
  #           single sample. Else if specified returns an array of that length.
  #  - block: Function for retrieving the absolute weight of each object.
  #
  # Returns a single item if count is not provided, else an array of samples.
  def weighted_sample_by(count=nil)
    wraw = each_with_object({}) { |obj, h| h[obj] = yield(obj) }
    wsum = wraw.values.inject(&:+)
    weights = wraw.keys.each_with_object({}) { |obj, h| h[obj] = Float(wraw[obj]) / wsum }
    results = (count || 1).times.map do
      weights.max_by { |_obj, weight| rand ** (1.0 / weight) }.first
    end
    count.nil? ? results.first : results
  end

  # Variation to invert the weights. Inverting is a bit subjective. I've gone
  # with a formula that calculates the difference from the original maximum. In
  # addition, I'm also adding a constant so that the max retains a nonzero
  # adjusted weight, and items with perfectly equal input weights converge on
  # equal final probability.
  def inverse_weighted_sample_by(count=nil)
    wraw = each_with_object({}) { |obj, h| h[obj] = yield(obj) }
    wmax = wraw.values.max
    weights = {}
    wraw.keys.each { |obj| weights[obj] = wmax - wraw[obj] + 1 }
    weighted_sample_by(count) { |obj| weights[obj] }
  end

  # Weighted sample sugar for objects that respond to #weight
  def weighted_sample(count=nil)
    weighted_sample_by(count) { |obj| obj.weight }
  end

  # Inverse weighted sample sugar for objects that respond to #weight
  def inverse_weighted_sample(count=nil)
    inverse_weighted_sample_by(count) { |obj| obj.weight }
  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/enumerable_weighted_sample.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
