Hollerback
==========

[![Build Status](https://travis-ci.org/delner/hollerback.svg?branch=master)](https://travis-ci.org/delner/hollerback) ![Gem Version](https://img.shields.io/gem/v/hollerback.svg?maxAge=2592000)
###### *For Ruby 2+*

### Introduction

Hollerback adds the callback pattern to your application, allowing you to easily implement DSL-like event handling to your application.

```ruby
note = NoteApi.get_note("Grocery List") do |on|
  on.found do |note|
    puts "Found an existing note!"
  end
  on.not_found do |name|
    puts "Note is missing! Creating a new one."
    Note.create!(name: name)
  end
  on.error do |error|
    puts "Failed to retrieve note!"
  end
end
```

### Installation

##### If you're not using Bundler...

Install the gem via:

```
gem install hollerback
```

Then require it into your application with:

```
require 'hollerback'
```

##### If you're using Bundler...

Add the gem to your Gemfile:

```
gem 'hollerback'
```

And then `bundle install` to install the gem and its dependencies.

### Usage

Enable the callback pattern by including the `Hollerback` module into the class/module you want to trigger callbacks.

```ruby
class NoteApi
  include Hollerback

  def get_note(name)
    # ...
  end
end
```

Then add a `&block` argument to the function you want to be callback enabled.

```ruby
class NoteApi
  include Hollerback

  def get_note(name, &block)
    # ...
  end
end
```

And use `hollerback_for` to get a set of callbacks you can invoke:

```ruby
class NoteApi
  include Hollerback

  def get_note(name, &block)
    hollerback_for(block) do |callbacks|
      # ...
    end
  end
end
```

Then trigger callbacks as you like, passing any arguments you need.

```ruby
class NoteApi
  include Hollerback

  def get_note(name, &block)
    # Creates Callbacks object from the block
    hollerback_for(block) do |callbacks|
      begin
        # Retrieves a HTTP response
        response = make_note_request(name: name)

        # Invoke Callbacks
        when response.status
        case 200
          callbacks.respond_with(:found, response.body)
        case 404
          callbacks.respond_with(:not_found, name)
        end
      rescue => e
        callbacks.respond_with(:error, e) 
      end
    end
  end
end
```

And finally use your newly callback-enabled function with your callback DSL:

```ruby
def write_note(name, content)
  note = NoteApi.new.get_note("Grocery List") do |on|
    on.found do |note_json|
      Note.from_json(note_json)
    end
    on.not_found do |name|
      Note.create!(name: name)
    end
    on.error do |error|
      raise "Failed to retrieve note! Reason: #{error.message}"
    end
  end

  note.append(content)
end
```

### Features

##### #hollerback_for

Converts an anonymous callback block into a `Hollerback::Callbacks` object that you can invoke callbacks from. Can be called as an instance or class method from any class that includes `Hollerback`.

```ruby
class NoteApi
  include Hollerback

  def self.get_note(name, &block)
    hollerback_for(block) do |callbacks|
      # ...
    end
  end

  def get_note(name, &block)
    hollerback_for(block) do |callbacks|
      # ...
    end
  end
end
```

This is the equivalent of:

```ruby
def get_note(name, &block)
  callbacks = Hollerback::Callbacks.new(block)
end
```

If you override the behavior of `Hollerback::Callbacks` in a subclass, you can use it as your callbacks object instead:

```ruby
class NoteCallbacks < Hollerback::Callbacks
  # ...
end

class NoteApi
  include Hollerback

  def get_note(name, &block)
    hollerback_for(block, callback_class: NoteCallbacks) do |callbacks|
      # ...
    end
  end
end
```

##### #respond_with

Triggers a callback, passing any arguments along. If the callback isn't defined, it raises a `NoMethodError`.

```ruby
callbacks_block = Proc.new do |on|
  on.no_args { "No args." }
  on.with_args { |a, b|  "#{a}, #{b}" }
  on.with_arg_list { |*args| args }
  on.with_arg_block { |&block| block.call }
end

callbacks = Hollerback::Callbacks.new(callbacks_block)

callbacks.respond_with(:no_args)
# => "No args."
callbacks.respond_with(:with_args, 1, 2)
# => "1, 2"
callbacks.respond_with(:with_arg_list, *[1,2,3])
# => [1,2,3]
callbacks.respond_with(:with_arg_block, &(Proc.new { "Block called." }))
# => "Block called."
callbacks.respond_with(:some_nonexisting_callback)
# => NoMethodError: No callback 'some_nonexisting_callback' is defined.
```

##### #try_respond_with

Triggers a callback like `respond_with`, passing any arguments along. If the callback isn't defined, it returns `nil`.

```ruby
callbacks_block = Proc.new do |on|
  on.no_args { "No args." }
end

callbacks = Hollerback::Callbacks.new(callbacks_block)

callbacks.try_respond_with(:no_args)
# => "No args."
callbacks.try_respond_with(:some_nonexisting_callback)
# => nil
```

### Testing

If you're writing RSpec tests around code that uses callbacks, you can mock callbacks using the `rspec-hollerback-mocks` gem.

```ruby
it { expect(NoteApi).to receive(:get_note).with(name).and_callback(:found, note) }
```

Check out the [`rspec-hollerback-mocks`](https://github.com/delner/rspec-hollerback-mocks) gem to learn more.

## Development

Install dependencies using `bundle install`. Run tests using `bundle exec rspec`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/delner/hollerback.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

