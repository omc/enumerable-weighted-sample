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

class Array
  include EnumerableWeightedSample
end
