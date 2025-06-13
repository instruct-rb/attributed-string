class AttributedString < String
  # This character Object Replacement Character is used to represent an attachment in the string.
  ATTACHMENT_CHARACTER = "\u{FFFC}".freeze

  # Adds an attachment to the given position.
  # @param attachment [Object] The attachment to add.
  # @param position [Integer] The position to add the attachment to.
  # @return [AttributedString] self for chaining
  def add_attachment(attachment, position: self.length)
    self.insert(position, ATTACHMENT_CHARACTER)

    range = normalize_range(position..position)
    raise ArgumentError, "Position out of bounds" if range.nil?
    @store << { range:, attachment: }
    self
  end

  # Deletes the attachment at a specific position.
  # @param position [Integer] The index in the string.
  # @return [Object] The attachment that was removed.
  def delete_attachment(position)
    attachment = attachment_at(position)
    self[position] = ''
    attachment
  end

  # Check if the string has an attachment
  # @param range [Range] The range to check for attachments.
  # @return [Boolean] Whether the string has an attachment at the given position.
  def has_attachment?(range: 0...self.length)
    range = normalize_range(range)
    return false if range.nil?
    (self.to_s[range]||'').include?(ATTACHMENT_CHARACTER)
  end

  # Returns the attachments at a specific position.
  # @param position [Integer] The index in the string.
  # @return <Object> The attachments at the given position.
  def attachment_at(position)
    result = nil
    @store.each do |stored_val|
      if stored_val[:range].begin == position && stored_val[:attachment]
        result = stored_val[:attachment]
      end
    end
    result
  end

  # Returns an array of attachments in the given range.
  # @param range [Range] The range to check for attachments.
  # @return [Array<Object>] The attachments in the given range.
  def attachments(range: 0...self.length)
    attachments_with_positions(range: range).map { |attachment| attachment[:attachment] }
  end

  def attachments_with_positions(range: 0...self.length)
    range = normalize_range(range)
    return [] if range.nil?
    @store.each_with_object([]) do |entry, arr|
      if entry[:attachment] && range.include?(entry[:range].begin)
        arr << { attachment: entry[:attachment], position: entry[:range].begin }
      end
    end
  end
end
