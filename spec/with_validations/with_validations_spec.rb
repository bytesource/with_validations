# encoding: utf-8

require 'spec_helper'

describe WithValidations do


  let(:mod) { described_class }


  before(:all) do
    class TestClass
      include WithValidations

      OPTIONS = {compact:     [false,    lambda {|value| is_boolean?(value) }],
                 with_pinyin: [true,     lambda {|value| is_boolean?(value) }],
                 size:        [:average, lambda {|value| [:short, :average, :long].include?(value) }]}

      def calls_validate(options={})
        @compress = validate { :compact }
        @compress
      end

      def calls_validate_with_strict(options={})
        @compress = validate(true) { [:compact, :with_pinyin] }
        [@compress, @with_pinyin, @size]
      end

      def self.calls_validate(options={})
        # @compress, @with_pinyin, @size = validate { [:compact, :with_pinyin, :size] }
        @compress, @with_pinyin, @size = validate { [:compact, :with_pinyin, :size] }
        [@compress, @with_pinyin, @size]
      end

      # With errors
      def calls_validate_key_not_found(options={})
        @compress = validate { 'a string' }
        @compress
      end

    end
  end

  context "When TestClass includes the module" do

    it "should add all of the module's methods as BOTH instance and singleton methods" do

      mod.instance_methods(false).all? do |m|
        TestClass.new.respond_to?(m)
        TestClass.respond_to?(m)
      end
    end


    context :validate do

        # Option hash
        # All options provided
        options_complete_no_defaults     = {compact: true, with_pinyin: false, size: :short}
        options_not_complete_no_defaults = {with_pinyin: false, size: :short}  # :compact not passed
        options_includes_unsupported_key = {compact: true, with_pinyin: false, size: :short, unsupported: '', not_valid: ''}
        options_no_keys                  = {}
        options_with_invalid_value       = {compact: true, with_pinyin: false, size: 'invalid'}

      context "On Failure" do

        it "should raise an exception if no block is given" do

          lambda do
            TestClass.new.validate
          end.should raise_exception(ArgumentError, /No block given/)
        end

        it "should raise an exception if the block is empty" do

          lambda do
            TestClass.new.validate {    }
          end.should raise_exception(ArgumentError, /Block is empty/)
        end

        it "With the optional parameter 'strict' set to 'true', it should raise an exception if a key from the options hash
         is not part of the keys given in the block" do

          lambda do
            TestClass.new.calls_validate_with_strict(options_includes_unsupported_key)
          end.should raise_exception(Exception, /not supported: size, unsupported, not_valid/)
        end


        it "should raise an exception if a key given in the block is not found in OPTIONS" do

          lambda do
            TestClass.new.calls_validate_key_not_found
          end.should raise_exception(ArgumentError, /'a string' passed to the block not found in OPTIONS/)
        end


        it "should raise an exception if a key value is invalid" do

          lambda do
            TestClass.calls_validate(options_with_invalid_value)
          end.should raise_exception(ArgumentError, /'invalid'/)
        end
      end

      context "On success" do

        context "When ALL keys in the block are found in the 'options' variable" do

          it "should return the values in options" do

            TestClass.calls_validate(options_complete_no_defaults).should     == [true, false, :short]
            TestClass.new.calls_validate(options_complete_no_defaults).should == true
          end

          context "When a key in the block is NOT found in the 'options' variable" do

            it "should return the values in options for all keys found in 'options', and return the default value otherwise" do

              TestClass.calls_validate(options_not_complete_no_defaults).should     == [false, false, :short]
              TestClass.new.calls_validate(options_not_complete_no_defaults).should == false

              TestClass.calls_validate(options_no_keys).should     == [false, true, :average]
              TestClass.new.calls_validate(options_no_keys).should == false
            end
          end

          context "When an unknown key is passed in the 'options' variable" do

            it "should ignore the unknown key and only handle the supported keys" do

              TestClass.calls_validate(options_includes_unsupported_key).should     == [true, false, :short]
              TestClass.new.calls_validate(options_includes_unsupported_key).should == true
            end
          end

        end
      end
    end

    context :extract_options do

      it "it should return a copy of the hash with the keys passed as an array (if present in hash)" do

        hash = {a: 'a', b: 'b', c: 'c', d: 'd', e: 'e'}
        keys = [:b, :c, :d, :z]

        TestClass.extract_options(keys, hash).should     ==  {b: 'b', c: 'c', d: 'd'}
        TestClass.new.extract_options(keys, hash).should ==  {b: 'b', c: 'c', d: 'd'}
      end
    end



    context :is_boolean? do

      specify {TestClass.is_boolean?(true).should be_true }
      specify {TestClass.is_boolean?(false).should be_true }
      specify {TestClass.is_boolean?('true').should be_false }
      specify {TestClass.is_boolean?(:true).should be_false }
    end

  end
end
