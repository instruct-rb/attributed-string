require 'test_helper'

class EachSpanWithAttrsTest < Minitest::Test
  def test_yields_spans_and_attributes
    str = AttributedString.new('Hello')
    str.add_attrs(0..1, bold: true)
    str.add_attrs(3..4, italic: true)

    spans = str.each_span_with_attrs.to_a
    assert_equal [
      ['He', { bold: true }, 0..1],
      ['l', {}, 2..2],
      ['lo', { italic: true }, 3..4]
    ], spans
  end

  def test_attribute_removal_creates_new_span
    str = AttributedString.new('abc')
    str.add_attrs(0..2, bold: true)
    str.remove_attrs(1..1, :bold)

    spans = str.each_span_with_attrs.to_a
    assert_equal [
      ['a', { bold: true }, 0..0],
      ['b', {}, 1..1],
      ['c', { bold: true }, 2..2]
    ], spans
  end

  def test_array_attributes_accumulate
    str = AttributedString.new('abc')
    str.add_arr_attrs(0..1, tag: :x)
    str.add_arr_attrs(1..2, tag: :y)

    spans = str.each_span_with_attrs.to_a
    assert_equal [
      ['a', { tag: [:x] }, 0..0],
      ['b', { tag: [:x, :y] }, 1..1],
      ['c', { tag: [:y] }, 2..2]
    ], spans
  end

  def test_attachments_do_not_create_new_spans
    str = AttributedString.new('ab')
    str.add_attrs(0..1, bold: true)
    str.add_attachment('img', position: 1)

    spans = str.each_span_with_attrs.to_a
    assert_equal [
      ['a', { bold: true }, 0..0],
      [AttributedString::ATTACHMENT_CHARACTER, {}, 1..1],
      ['b', { bold: true }, 2..2]
    ], spans
  end
end
