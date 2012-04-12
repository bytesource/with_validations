# encoding: utf-8
require "with_validations/version"
require 'with_validations/core_ext/hash'

module WithValidations

  # In order to be able to validate options in both
  # instance and singleton methods,
  # the following method makes sure that all module methods are available
  # as both instance and singleton methods.
  def self.included(klass)
    klass.extend(self)
  end


  # Validates the options passed in the block.
  #  Options can either be a single option key or an array of options keys.
  #  Option keys and their values are validated based on the information given in a
  #  mandatory constant called `OPTIONS`. Keys from a methods `options` has that are not listed in `OPTIONS` are ignored.
  # @note A class that includes this module is required to:
  #
  #  * provide a constant named `OPTIONS` with a hash of the following type:
  #   `{ option_key => [default_value, validation_proc], ...}`.
  #  * name the optional option hash of a method `options`.
  # @overload validate(strict)
  #  @param [Boolean] strict Whether or not raise an exception if the options has contains any unsupported keys.
  #    Default: `false`
  # @overload validate()
  # @return [Array, Object] If more than one keys are evaluated, return an array of the key values, otherwise returns a single value.
  # @example
  #  require 'with_validations'
  #
  #   class TestClass
  #     include WithValidations
  #
  #     # option_key => [default_value, validation_proc]
  #     OPTIONS = {:compact      => [false, lambda {|value| is_boolean?(value) }],
  #                :with_pinyin  => [true,  lambda {|value| is_boolean?(value) }],
  #                :thread_count => [8,     lambda {|value| value.kind_of?(Integer) }]}
  #
  #     # Instance method
  #     def test_method_1(options={})
  #       @thread_count = validate { :thread_count }
  #       # ...
  #     end
  #
  #     # Singleton method
  #     def self.test_method_2(options={})
  #       @compact, @with_pinyin = validate { [:compact, :with_pinyin] }
  #       # ...
  #     end
  #
  #     # Optional parameter set to true.
  #     def self.test_method_3(options={})
  #       @compact, @with_pinyin = validate(true) { [:compact, :with_pinyin] }
  #       #...
  #     end
  #
  #     #...
  #   end
  def validate(strict = false, &block)
    raise ArgumentError, "No block given" unless block

    argument = block.call
    # Raise exception if the block is empty.
    raise ArgumentError, "Block is empty"  if argument.nil?

    keys = Array(argument) # Wrap single key as array. If passed an array, just return the array.

    constant = eval("OPTIONS", block.binding)
    options  = eval("options", block.binding) # Alternative: constant = block.binding.eval("OPTIONS")

    # Handling optional argument 'strict'
    ops = options.dup
    ops.delete_keys!(*keys)
    # If 'strict' is set to 'true', any key from the options key that is not part of the keys
    # passed to the block will throw an exception.
    raise Exception, "The following keys are not supported: #{ops.keys.join(', ')}"  if ops.size > 0 && strict

    values = keys.map do |key|
      # Raise exception if 'key' from the block is NOT a key in the OPTIONS constant.
      raise ArgumentError, "Key '#{key}' passed to the block not found in OPTIONS" unless constant.keys.include?(key)

      if options.has_key?(key) # Supported key in block found in options => extract its value from options.
        value = options[key]
        # Check if 'value' is a valid value.
        validation = constant[key][1]
        if validation.call(value)    # Validation passed => return value from options
          value
        else                         # Validation failed => raise exception
          raise ArgumentError, "'#{value}' (#{value.class}) is not a valid value for key '#{key}'."
        end
      else # Supported key in block not found in options => return its default value.
        default_value = constant[key][0]
        default_value
      end
    end

    values.size > 1 ? values : values [0]
  end

  # Returns a new hash from `options` based on the keys in `*keys`.
  #  in `arr`. Keys in `arr` not found in `options` are ignored.
  #  *Use case*: When a method's options hash contains options for another method
  #  that throws an exeption if the options hash contains keys not handled internally (Example: CSV library)
  #  the options special to that method need to be extracted before passed as an argument.
  # @return [Hash]
  # @example
  #   def sample_method(text, options={})
  #     @compact, @with_pinyin = validate { [:compact, :with_pinyin] }
  #
  #     csv_options = extract_options(CSV::DEFAULT_OPTIONS.keys, options)
  #     csv = CSV.parse(text, csv_options)
  #     #...
  #   end
  def extract_options(arr, options)
    options.slice(*arr)
  end



  # Some useful validation methods
  # =============================

  # Helper method that can be used in a validation proc.
  # @return [true, false] Returns `true` if the argument passed is either `true` or `false`.
  #   Returns `false` on any other argument.
  def is_boolean?(value)
    # Only true for either 'false' or 'true'
    !!value == value
  end

end
