# -*- coding: us-ascii -*-
# frozen_string_literal: false
require 'test_helper'

class TestData < Minitest::Test
  def test_define
    klass = Data.define(:foo, :bar)
    assert_kind_of(Class, klass)
    assert_equal(%i[foo bar], klass.members)

    assert_raises(NoMethodError) { Data.new(:foo) }
    assert_raises(TypeError) { Data.define(0) }

    # Because some code is shared with Struct, check we don't share unnecessary functionality
    assert_raises(TypeError) { Data.define(:foo, keyword_init: true) }
  end

  def test_define_edge_cases
    # non-ascii
    klass = Data.define(:"r\u{e9}sum\u{e9}")
    o = klass.new(1)
    assert_equal(1, o.send(:"r\u{e9}sum\u{e9}"))

    # junk string
    klass = Data.define(:"a\000")
    o = klass.new(1)
    assert_equal(1, o.send(:"a\000"))

    # special characters in attribute names
    klass = Data.define(:a, :b?)
    x = Object.new
    o = klass.new("test", x)
    assert_same(x, o.b?)

    klass = Data.define(:a, :b!)
    x = Object.new
    o = klass.new("test", x)
    assert_same(x, o.b!)

    assert_raises(ArgumentError) { Data.define(:x=) }
    assert_raises(ArgumentError, /duplicate member/) { Data.define(:x, :x) }
  end

  def test_define_with_block
    klass = Data.define(:a, :b) do
      def c
        a + b
      end
    end

    assert_equal(3, klass.new(1, 2).c)
  end

  def test_initialize
    klass = Data.define(:foo, :bar)

    # Regular
    test = klass.new(1, 2)
    assert_equal(1, test.foo)
    assert_equal(2, test.bar)
    assert_equal(test, klass.new(1, 2))

    # Keywords
    test_kw = klass.new(foo: 1, bar: 2)
    assert_equal(1, test_kw.foo)
    assert_equal(2, test_kw.bar)
    assert_equal(test_kw, klass.new(foo: 1, bar: 2))
    assert_equal(test_kw, test)

    # Wrong protocol
    assert_raises(ArgumentError) { klass.new(1) }
    assert_raises(ArgumentError) { klass.new(1, 2, 3) }
    assert_raises(ArgumentError) { klass.new(foo: 1) }
    assert_raises(ArgumentError) { klass.new(foo: 1, bar: 2, baz: 3) }
    # Could be converted to foo: 1, bar: 2, but too smart is confusing
    assert_raises(ArgumentError) { klass.new(1, bar: 2) }
  end

  def test_initialize_redefine
    klass = Data.define(:foo, :bar) do
      attr_reader :passed

      def initialize(*args, **kwargs)
        @passed = [args, kwargs]

        super(foo: 1, bar: 2) # so we can experiment with passing wrong numbers of args
      end
    end

    assert_equal([[], {foo: 1, bar: 2}], klass.new(foo: 1, bar: 2).passed)

    # Positional arguments are converted to keyword ones
    assert_equal([[], {foo: 1, bar: 2}], klass.new(1, 2).passed)

    # Missing arguments can be fixed in initialize
    assert_equal([[], {foo: 1}], klass.new(foo: 1).passed)

    # Extra keyword arguments can be dropped in initialize
    assert_equal([[], {foo: 1, bar: 2, baz: 3}], klass.new(foo: 1, bar: 2, baz: 3).passed)
  end

  def test_instance_behavior
    klass = Data.define(:foo, :bar)

    test = klass.new(1, 2)
    assert_equal(1, test.foo)
    assert_equal(2, test.bar)
    assert_equal(%i[foo bar], test.members)
    assert_equal(1, test.public_send(:foo))
    assert_equal(0, test.method(:foo).arity)
    assert_equal([], test.method(:foo).parameters)

    assert_equal({foo: 1, bar: 2}, test.to_h)
    assert_equal({"foo"=>"1", "bar"=>"2"}, test.to_h { [_1.to_s, _2.to_s] })

    assert_equal({foo: 1, bar: 2}, test.deconstruct_keys(nil))
    assert_equal({foo: 1}, test.deconstruct_keys(%i[foo]))
    assert_equal({foo: 1}, test.deconstruct_keys(%i[foo baz]))
    assert_raises(TypeError) { test.deconstruct_keys(0) }

    test = klass.new(bar: 2, foo: 1)
    assert_equal([1, 2], test.deconstruct)

    assert_predicate(test, :frozen?)

    assert_kind_of(Integer, test.hash)
  end

  def test_inspect
    klass = Data.define(:a)
    o = klass.new(1)
    assert_equal("#<data a=1>", o.inspect)

    Object.const_set(:Foo, klass)
    assert_equal("#<data Foo a=1>", o.inspect)
    Object.instance_eval { remove_const(:Foo) }

    klass = Data.define(:@a)
    o = klass.new(1)
    assert_equal("#<data :@a=1>", o.inspect)

    klass = Data.define(:one, :two)
    o = klass.new(1,2)
    assert_equal("#<data one=1, two=2>", o.inspect)
    assert_equal("#<data one=1, two=2>", o.to_s)
  end

  def test_equal
    klass1 = Data.define(:a)
    klass2 = Data.define(:a)
    o1 = klass1.new(1)
    o2 = klass1.new(1)
    o3 = klass2.new(1)
    assert_equal(o1, o2)
    refute_equal(o1, o3)
  end

  def test_eql
    klass1 = Data.define(:a)
    klass2 = Data.define(:a)
    o1 = klass1.new(1)
    o2 = klass1.new(1)
    o3 = klass2.new(1)
    assert_operator(o1, :eql?, o2)
    refute_operator(o1, :eql?, o3)
  end

  def test_memberless
    klass = Data.define

    test = klass.new

    assert_equal(klass.new, test)
    refute_equal(Data.define.new, test)

    assert_equal('#<data >', test.inspect)
    assert_equal([], test.members)
    assert_equal({}, test.to_h)
  end

  def test_square_braces
    klass = Data.define(:amount, :unit)

    distance = klass[10, 'km']

    assert_equal(10, distance.amount)
    assert_equal('km', distance.unit)
  end

  def test_namespaced_constant
    klass = Data.define("Measure", :amount, :unit)

    assert_equal(Data::Measure, klass)
  end
end
