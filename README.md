# WithValidations

### Easy validation of option keys and their values.

## Features

* Validate If all option values are valid.
* Automatically assign default values to missing but required keys.
* (Optionally) check for unsupported keys in the options hash.
* Assign the validated values to one or more variables.


## Installation

``` bash
$ gem install with_validations
```

## Usage

__Note__: A class including this module also need to stick to the following conventions:

* Provide a hash of the type `{ option_key => [default_value, validation_proc], ...}`
  assigned to a constant named `OPTIONS`.
* Name the option hash of a method `options`.

### Sample Setup

````ruby
require 'with_validations'

class TestClass
  include WithValidations

  # option_key => [default_value, validation_proc]
  OPTIONS = {:compact      => [false, lambda {|value| is_boolean?(value) }],
             :with_pinyin  => [true,  lambda {|value| is_boolean?(value) }],
             :thread_count => [8,     lambda {|value| value.kind_of?(Integer) }]}

  # Instance method
  def test_method_1(options={}) # options hash has to be named 'options'
    @thread_count = validate { :thread_count }

    #...
  end

  # Singleton method
  def self.test_method_2(options={})
    @compact, @with_pinyin = validate { [:compact, :with_pinyin] }

    # ...
  end

  # Optional parameter set to true.
  def self.test_method_3(options={})
    @compact, @with_pinyin = validate(true) { [:compact, :with_pinyin] }

    # ...
  end

  #...
end
````

#### Use Cases

```` ruby
obj = TestClass.new
obj.test_method_1(:thread_count => 10)
# @thread_count set to 10

# No options hash passed, used default value
my_class.test_method_1
# @thread_count set to 8

# Passing any invalid value
my_class.test_method_1(:thread_count => 'invalid')
# ArgumentError: Value 'invalid' is not a valid value for key 'thread_count'


TestClass.test_method_2(:compact => true, :with_pinyin => false)
# @compact set to true, @with_pinyin set to false

TestClass.test_method_2(:compact => true)
# No options for key :with_pinyin provided: Use the default value
# @compact is set to true, @with_pinyin is set to true

# By default, any keys from the options hash that are not part of the block are ignored.
TestClass.test_method_2(:compact => true,
                        :with_pinyin => false,
                        :thread_count => 10,           # Key in OPTIONS, but not part of the block.
                        :not_listed => 'some value')   # Not part of the block
# @compact set to true, @with_pinyin set to false

# Optional argument set to true: Any key from the options hash that is not part of the keys
     # passed to the block will throw an exception.
TestClass.test_method_3(:compact => true,
                        :with_pinyin => false,
                        :thread_count => 10,           # Key in OPTIONS, but not part of the block.
                        :not_listed => 'some value')   # Not part of the block
# Exception: The following keys are not supported: not_listed
````

## Documentation

### Main method

* [validate](http://rubydoc.info/github/bytesource/with_validations/master/WithValidations:validate)
### Optional methods

* [extract_options](http://rubydoc.info/github/bytesource/with_validations/master/WithValidations:extract_options)
* [is_boolean?](http://rubydoc.info/github/bytesource/with_validations/master/WithValidations:is_boolean%3F)

__Note__: All methods are available as both instance and singleton methods.
