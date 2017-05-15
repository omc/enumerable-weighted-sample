require "enumerable_weighted_sample/version"

module EnumerableWeightedSample

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

end


# Run this file directly for some quick and dirty inline testing
if $0 == __FILE__

  class Array
    def summarize
      each_with_object(Hash.new(0)){|foo,h| h[foo] += 1 }.pretty
    end
    def pretty
      map(&:inspect).join(", ")
    end
  end

  class Hash
    def pretty
      sort_by{|_k,v|v}.map{|k,v| "#{k}: #{v}" }.join(", ")
    end
  end

  class Foo
    attr_accessor :name, :weight
    def initialize(name, weight)
      self.name = name
      self.weight = weight
    end
    def to_s
      name
    end
    def inspect
      "#{name}: #{weight}"
    end
  end

  SAMPLES = 1_000

  things = [
    Foo.new("foo",   1),
    Foo.new("bar",   2),
    Foo.new("baz", 199),
    Foo.new("bat", 198)
  ]

  # puts things.inverse_weighted_sample(100).summarize

  puts "input weights:"
  puts things.pretty
  puts

  puts "#{SAMPLES}x weighted samples:"
  weighted_things = things.weighted_sample(SAMPLES)
  puts weighted_things.map(&:name).summarize
  puts

  puts "#{SAMPLES}x inverse weighted samples:"
  inverse_weighted_things = things.inverse_weighted_sample(SAMPLES)
  puts inverse_weighted_things.map(&:name).summarize
  puts

  puts "#{SAMPLES}x iterative rebalance:"
  SAMPLES.times do
    things.weighted_sample.weight -= 1
    things.inverse_weighted_sample.weight += 1
  end
  puts things.pretty

end
