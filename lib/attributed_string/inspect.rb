class AttributedString
# Inspect prints the attributed string in an easily readable way.
# An example inspect output "{ k1: 1 }these have the attributes k1: 1 { k1: 2, k2: true }these have 2 attrs k1: 2, and k2: true { -k2 }and these have k1: 2 { -k1 }and these have none"
# could be constructed as:
#
#   ("these have the attributes k1: 1 ".to_attr_s(k1: 1) +
#   "these have 2 attrs k1: 2, and k2: true ".to_attr_s(k1: 2, k2: true) +
#   "and these have k1: 2 ".to_attr_s(k1: 2) +
#   "and these have none").inspect
#
  def inspect(color: false)
    attachments_map = attachments_with_positions(range: 0...length).each_with_object({}) do |entry, h|
      h[entry[:position]] = entry[:attachment]
    end

    result = ""
    last_attrs = {}

    each_span_with_attrs.with_index do |(substring, attrs, range), span_idx|
      ended_attrs = {}
      started_attrs = {}

      last_attrs.each do |key, value|
        if !attrs.key?(key)
          ended_attrs[key] = value
        elsif attrs[key] != value
          ended_attrs[key] = value
          started_attrs[key] = attrs[key]
        end
      end

      attrs.each do |key, value|
        started_attrs[key] = value unless last_attrs.key?(key)
      end

      ended_attrs.delete_if { |k, _| started_attrs.key?(k) }

      unless ended_attrs.empty? && started_attrs.empty?
        attrs_str = ended_attrs.keys.sort.map { |k| "-#{k}" }
        attrs_str += started_attrs.sort_by { |a, _| a }.map { |k, v| "#{k}: #{v}" }
        result << dim("{ #{attrs_str.join(', ')} }", color: color)
      end

      substring.chars.each_with_index do |char, i|
        pos = range.begin + i
        if char.to_s == ATTACHMENT_CHARACTER && attachments_map.key?(pos)
          result << dim("[#{attachments_map[pos]}]", color: color)
        else
          result << char
        end
      end

      last_attrs = attrs
    end

    unless last_attrs.empty?
      result << dim("{ #{last_attrs.keys.sort.map { |k| "-#{k}" }.join(', ')} }", color: color)
    end

    result
  end

  def dim(string, color: true)
    color ? "\e[2m#{string}\e[22m" : string
  end
end
