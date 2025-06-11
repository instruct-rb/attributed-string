require 'test_helper'

class InitializersTest < Minitest::Test
  using AttributedString::Refinements

  def test_can_create_new_with_no_args
    attr_string = AttributedString.new
    assert attr_string.to_s == ""
  end

  def test_can_create_new_with_string
    attr_string = AttributedString.new("Hello, World!")
    assert attr_string.to_s == "Hello, World!"
  end

  def test_dup
    @attr_string.add_attrs(0..4, bold: true)
    dup = @attr_string.dup
    0.upto(4) do |i|
      assert_equal({ bold: true }, dup.attrs_at(i))
    end
    5.upto(12) do |i|
      assert_equal({}, dup.attrs_at(i))
    end
  end

  def test_dup_does_not_modify_original_store
    @attr_string.add_attrs(0..4, bold: true)
    original_range_id = @attr_string.instance_variable_get(:@store).first[:range].object_id
    @attr_string.dup
    after_range_id = @attr_string.instance_variable_get(:@store).first[:range].object_id
    assert_equal original_range_id, after_range_id
  end

end
