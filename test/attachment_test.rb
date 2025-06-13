require 'test_helper'

class AddingAttachmentTest < Minitest::Test
  def setup
    @str = AttributedString.new("a string")
    @str.add_attachment("attachment", position: 1)
  end

  def test_attachments_on_empty_string
    str = AttributedString.new("")
    assert_equal [], str.attachments
  end

  def test_adds_attachment_character
    assert_equal "a#{AttributedString::ATTACHMENT_CHARACTER} string", @str.to_s
  end

  def test_add_attachment_to_end
    @str.add_attachment("attachment2")
    assert_equal "a#{AttributedString::ATTACHMENT_CHARACTER} string#{AttributedString::ATTACHMENT_CHARACTER}", @str.to_s
  end

  def test_has_attachment
    assert @str.has_attachment?
    assert @str.has_attachment?(range: 1..1)
    assert @str.has_attachment?(range: 1...2)
    refute @str.has_attachment?(range: 0..0)
    refute @str.has_attachment?(range: 2..2)
  end

  def test_attachments
    @str.add_attachment("attachment2", position: 2)
    assert_equal ["attachment", "attachment2"], @str.attachments
    assert_equal ["attachment", "attachment2"], @str.attachments(range: 1..2)
    assert_equal ["attachment"], @str.attachments(range: 1..1)
    assert_equal ["attachment2"], @str.attachments(range: 2..2)
  end

  def replacing_the_character_makes_the_attachment_disappear
    assert_equal "attachment", @str.attachment_at(1)
    @str[1] = "b"
    assert_equal "ab string", @str.to_s
    assert_equal nil, @str.attachment_at(1)
  end

  def test_cannot_put_two_attachments_in_the_same_position
    @str.add_attachment("attachment2", position: 1)
    assert_equal "attachment2", @str.attachment_at(1)
    assert_equal "attachment", @str.attachment_at(2)
  end

  def test_adding_attachment_to_empty_string
    @str = AttributedString.new("")
    @str.add_attachment("attachment", position: 0)
    assert_equal "attachment", @str.attachment_at(0)
    assert_equal ["attachment"], @str.attachments
  end

  def test_accessing_attachment
    assert_nil @str.attachment_at(0)
    assert_equal "attachment", @str.attachment_at(1)
    assert_nil @str.attachment_at(2)
  end

  def test_range_movements
    str = AttributedString.new("1")
    str.concat(@str)
    assert_nil str.attachment_at(0)
    assert_nil str.attachment_at(1)
    assert_equal "attachment", str.attachment_at(2)
    assert_nil str.attachment_at(3)
  end

  def test_attachments_with_positions_entire_string
    @str.add_attachment("second", position: 3)
    results = @str.attachments_with_positions
    assert_equal [{ attachment: "attachment", position: 1 },
                  { attachment: "second", position: 3 }], results
  end

  def test_attachments_with_positions_in_range
    @str.add_attachment("second", position: 3)
    results = @str.attachments_with_positions(range: 3..3)
    assert_equal [{ attachment: "second", position: 3 }], results
  end

  def test_attachments_with_positions_invalid_range
    results = @str.attachments_with_positions(range: 100..101)
    assert_equal [], results
  end
end
