# AttributedString
[![Ruby](https://github.com/instruct-rb/attributed-string/actions/workflows/ruby.yml/badge.svg)](https://github.com/instruct-rb/attributed-string/actions/workflows/ruby.yml)
[![Gem Version](https://badge.fury.io/rb/attributed-string.svg)](https://badge.fury.io/rb/attributed-string)

An attributed string implementation for Ruby.

---
🚧 This gem is in development, and its behaviour might still change before 1.0 🚧

---


An attributed string contains key-value pairs known as attributes that specify additional information related to ranges of characters within the string. Attributed strings support any key-value pair, but are often used for:

- Rendering attributes such as font, color,  and other details.
- Attributes for inline-attachments such as images, videos, files, etc.
- Semantic attributes such as link URLs or tool-tip information
- Language attributes to support automatic gender agreement or verb agreement.
- Accessibility attributes that provide information for assistive technologies
- Custom attributes you define

You will typically need to create a presenter for an attributed string, as the default shows no attribute information and inspect shows all attributes.

This gem is inspired by Apple's [NSAttributedString](https://developer.apple.com/documentation/foundation/nsattributedstring).

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'attributed-string'
```


## Usage


```ruby
  using AttributedString::Refinements
  hello_world1 = AttributedString.new('Hello, World!',  color: :red, font: 'Helvetica' )
  hello_world2 = 'Hello, World!'.to_attr_s(color: :red, font: 'Helvetica')
  puts hello_world1 == hello_world2
  # => true

  hello_world1.add_attrs(0..4, color: :blue)
  hello_world1 += "!!"
  puts hello_world1.inspect
  # => { color: blue, font: "Helvetica" }Hello{ color: red }, World!{ -color, -font }!!

  puts hello_world1.attrs_at(0)
  # => { color: blue, font: "Helvetica" }
```

## Attachments

```ruby
  hello_world = AttributedString.new('Hello, World!')

  hello_world.add_attachment("any ruby object", position: string.length)

  # Adding an attachment inserts the Object Replacement Character into the
  # string, in most fonts it will show as a space
  puts hello_world
  # => "Hello, World! "
  puts hello_world.attachments # => ["any ruby object"]

  # Deleting the character from the string removes the attachment
  hello_world[-1..-1] = ''
  puts hello_world.attachments # => []
```

## Iterating Over Attribute Spans

`each_span_with_attrs` yields substrings where the active attributes do not
change. This allows efficient traversal of long strings with many attribute
ranges.

```ruby
  str = AttributedString.new('hello')
  str.add_attrs(0..1, bold: true)
  str.add_attrs(2..4, italic: true)

  str.each_span_with_attrs do |substring, attrs, range|
    p [substring, attrs, range]
  end
  # => ["he", { bold: true }, 0..1]
  # => ["l", {}, 2..2]
  # => ["lo", { italic: true }, 3..4]
```

## More Examples
See the [test suite](./test).

## Used By
- [Instruct](https://github.com/instruct-rb/instruct) - Instruct LLMs to do what you want in Ruby
