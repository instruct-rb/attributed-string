class AttributedString < String

  alias_method :original_slice, :slice
  private :original_slice

  # Returns a new instance of AttributedString with the kwargs passed in as
  # attributes for the whole string.
  # @param string [String]
  def initialize(string = "", **attrs)
    super(string)
    @store = []
    if string.is_a?(AttributedString)
      string.instance_variable_get(:@store).each do |entry|
        @store << entry.dup
      end
    end
    add_attrs(**attrs)
  end

  def dup
    super.tap do |copy|
      new_store = @store.map do |entry|
        entry_dup = entry.dup
        entry_dup[:range] = entry_dup[:range].dup
        entry_dup
      end
      copy.instance_variable_set(:@store, new_store)
    end
  end

  # Adds the given attributes in the hash to the range.
  # @param range [Range] The range to apply the attributes to.
  # @param attributes [Hash<Symbol, Object>] The attributes to apply to the range.
  # @return [AttributedString] self for chaining
  def add_attrs(range = 0..self.length - 1, **attributes)
    range = normalize_range(range)
    return self if attributes.empty? || self.empty? || range.nil? || range.size.zero?
    @store << { range: range, attributes: attributes }
    self
  end

  # Adds the given attributes in the hash to the range.
  #
  # If the attribute is already set, it will be converted to an array and the new value will be appended.
  #
  # @param range [Range] The range to apply the attributes to.
  # @param attributes [Hash<Symbol, Object>] The attributes to apply to the range.
  # @return [AttributedString] self for chaining
  def add_arr_attrs(range = 0..self.length - 1, **attributes)
    range = normalize_range(range)
    return self if attributes.empty? || self.empty? || range.nil? || range.size.zero?
    @store << { range: range, arr_attributes: attributes }
    self
  end



  # Need to think about how this works as the attachment store is an array
  # def remove_attachment(position)
  #   raise Todo
  # end


  # Removes the given attributes from a range.
  # @param range_or_key [Range] The range to remove the attributes from, if its not a range, it will be treated as a key to remove.
  # @param attribute_keys [Array<Symbol>] The keys of the attributes to remove.
  # @return [AttributedString] self for chaining
  def remove_attrs(range_or_key, *attribute_keys)
    if !range_or_key.is_a?(Range)
      attribute_keys << range_or_key
      range_or_key = 0..self.length - 1
    end
    @store << { range: range_or_key, delete: attribute_keys }
    self
  end

  # Returns the attributes at a specific position.
  # @param position [Integer] The index in the string.
  # @return [Hash] The attributes at the given position.
  def attrs_at(position)
    result = {}
    @store.each do |stored_val|
      if stored_val[:range].include?(position)
        if stored_val[:delete]
          stored_val[:delete].each do |key|
            result.delete(key)
          end
        elsif stored_val[:arr_attributes]
          stored_val[:arr_attributes].each do |key, value|
            result[key] = [result[key]] if result.key?(key) && !result[key].is_a?(Array)
            if value.is_a?(Array)
              (result[key] ||= []).concat(value)
            else
              (result[key] ||= []).push(value)
            end
          end
        elsif stored_val[:attributes]
          result.merge!(stored_val[:attributes])
        end
      end
    end
    result
  end

  def ==(other)
    return false unless other.is_a?(AttributedString)
    # not super efficient, but it works for now
    (0...length).all? { |i| attrs_at(i) == other.attrs_at(i) && attachment_at(i) == other.attachment_at(i) } && super
  end




end
