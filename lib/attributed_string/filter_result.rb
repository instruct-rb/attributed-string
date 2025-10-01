class AttributedString < String

  # Returns a filtered string the block will be called with each attribute,
  # value pair. It's an inclusive filter, so if the block returns true, any
  # character with that attribute will be included.
  #
  # This method has been slightly optimized to minimize allocations.
  # @see AttributedString#filter
  # @param attr_string [AttributedString]
  # @param block [Proc] the block to filter the attributes.
  # @return [AttributedString::FilterResult] a filtered string.
  def filter(&block)
    AttributedString::FilterResult.new(self, &block)
  end

  class FilterResult < String
    # @see AttributedString#filter
    def initialize(attr_string, &block)
      result_parts = []
      ranges = []
      cached_block_calls = {}

      attr_string.each_span_with_attrs do |substring, attrs, range|
        cache_key = attrs.hash
        keep = cached_block_calls.fetch(cache_key) do
          res = block.call(attrs)
          cached_block_calls[cache_key] = res
          res
        end
        next unless keep

        result_parts << substring

        if ranges.any? && ranges.last.end == range.begin - 1
          last = ranges.pop
          ranges << (last.begin..range.end)
        else
          ranges << range
        end
      end

      result_string = result_parts.join
      original_positions = ranges.flat_map { |r| r.to_a }

      super(result_string)
      @original_positions = original_positions
      freeze
    end

    def original_position_at(index)
      @original_positions.fetch(index)
    end

    def original_ranges_for(filtered_range)
      raise ArgumentError, "Invalid range" unless filtered_range.is_a?(Range)

      end_idx = filtered_range.end
      end_idx -= 1 if filtered_range.exclude_end?
      raise ArgumentError, "Range out of bounds" if end_idx >= length

      if filtered_range.begin > end_idx
        return [] if filtered_range.begin == end_idx + 1 && filtered_range.exclude_end?
        raise ArgumentError, "Reverse range is not allowed"
      end

      original_positions = @original_positions[filtered_range]
      ranges = []
      start_pos = original_positions.first
      prev_pos = start_pos

      original_positions.each_with_index do |pos, idx|
        next if idx == 0
        if pos == prev_pos + 1
          # Continue the current range
          prev_pos = pos
        else
          # End the current range and start a new one
          ranges << (start_pos..prev_pos)
          start_pos = pos
          prev_pos = pos
        end
      end
      # Add the final range
      ranges << (start_pos..prev_pos)
      ranges
    end
  end
end
