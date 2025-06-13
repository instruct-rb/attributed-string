require 'test_helper'
require 'minitest/benchmark'

# Benchmarks for common AttributedString operations. These tests help
# identify operations that scale worse than linearly as the string or
# attribute count grows.
class BenchmarkPerformanceTest < Minitest::Benchmark
  # Use a modest range so the test suite stays fast while still
  # demonstrating growth trends.
  def self.bench_range
    bench_exp(10, 1_000, 10)
  end

  # Benchmark adding a single attribute over the entire string.
  # The operation should run in roughly constant time with respect to string
  # length because only the attribute list grows by one entry.
  def bench_add_attrs_whole_string
    assert_performance_constant do |n|
      str = AttributedString.new('a' * n)
      str.add_attrs(0...n, bold: true)
    end
  end

  # Benchmark looking up an attribute when many single-character ranges exist.
  def bench_attrs_at_many_ranges
    assert_performance_linear 0.90 do |n|
      str = AttributedString.new('a' * n)
      n.times { |i| str.add_attrs(i..i, index: i) }
      str.attrs_at(n / 2)
    end
  end

  # Benchmark inserting text in the middle of a heavily attributed string.
  def bench_insert_middle
    assert_performance_linear 0.90 do |n|
      str = AttributedString.new('a' * n)
      n.times { |i| str.add_attrs(i..i, index: i) }
      str.insert(n / 2, 'b')
    end
  end

  # Benchmark iterating over spans with many small attribute ranges.
  def bench_each_span_with_attrs
    assert_performance_linear 0.90 do |n|
      str = AttributedString.new('a' * n)
      n.times { |i| str.add_attrs(i..i, index: i) }
      str.each_span_with_attrs { |_sub, _attrs, _range| }
    end
  end

  # Benchmark filtering to build a new AttributedString when densely attributed.
  def bench_filter_dense
    assert_performance_linear 0.90 do |n|
      str = AttributedString.new('a' * n)
      n.times { |i| str.add_attrs(i..i, index: i) }
      str.filter { |attrs| attrs[:index].even? }
    end
  end

  # Benchmark inspect on a heavily attributed string.
  def bench_inspect_dense
    assert_performance_linear 0.90 do |n|
      str = AttributedString.new('a' * n)
      n.times { |i| str.add_attrs(i..i, index: i) }
      str.inspect
    end
  end
end
