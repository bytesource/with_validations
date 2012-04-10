# WithValidations

### Easy validation of one or more option keys and values using a single method.

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

__Note__: A class that includes this module is required to:

* provide a constant named `OPTIONS` with a hash of the following type:
`{ option_key => [default_value, validation_proc], ...}`.
* name the optional option hash of a method `options`.


````ruby
class TestClass
  include 'Options'

  # option_key => [default_value, validation_proc]
  OPTIONS = {:compact      => [false, lambda {|value| is_boolean?(value) }],
             :with_pinyin  => [true,  lambda {|value| is_boolean?(value) }],
             :thread_count => [8,     lambda {|value| value.kind_of?(Integer) }]}

  def test_method_1(options={})
    @thread_count = validate { :thread_count }
    # ...
  end

  def self.test_method_2(options={})
     # Optional argument set to true: Throw exception if the options hash contains any
     # unsupported keys.
    @compact, @with_pinyin = validate(true) { [:compact, :with_pinyin] }
    # ...
  end

  #...
end


my_class = TestClass.new
my_class.test_method_1(:thread_count => 10)
# @thread_count is set to 10

my_class.test_method_1(:thread_count => 10)
# @thread_count is set to 10

my_class.test_method_1(:thread_count => 10)
# @thread_count is set to 10

TestClass.test_method2(:compact => true, :with_pinyin => false)
# @compact is set to true, @with_pinyin is set to false

TestClass.test_method2
# No options provided: The default values from OPTIONS will be used
# @compact is set to false, @with_pinyin is set to true

TestClass.test_method2(:compact => true, :with_pinyin => false)
# @compact is set to true, @with_pinyin is set to false
````

## Documentation
### Main method

* [validate](http://rubydoc.info/github/bytesource/with_validations/WithValidations:validate)
### Optional methods

* [extract_options](http://rubydoc.info/github/bytesource/with_validations/WithValidations:extract_options)
* [is_boolean?](http://rubydoc.info/github/bytesource/with_validations/WithValidations:is_boolean?)

_Note_: All methods are available as both instance and singleton methods.
