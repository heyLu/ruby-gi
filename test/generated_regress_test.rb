require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Tests generated methods and functions in the Regress namespace.
class GeneratedRegressTest < Test::Unit::TestCase
  context "The generated Regress module" do
    setup do
      GirFFI.setup :Regress
      GirFFI.setup :GObject
      GirFFI.setup :GLib
      GirFFI.setup :Gtk
    end

    context "the Regress::TestBoxed class" do
      should "create an instance using #new" do
	tb = Regress::TestBoxed.new
	assert_instance_of Regress::TestBoxed, tb
      end

      should "create an instance using #new_alternative_constructor1" do
	tb = Regress::TestBoxed.new_alternative_constructor1 1
	assert_instance_of Regress::TestBoxed, tb
	assert_equal 1, tb[:some_int8]
      end

      should "create an instance using #new_alternative_constructor2" do
	tb = Regress::TestBoxed.new_alternative_constructor2 1, 2
	assert_instance_of Regress::TestBoxed, tb
	assert_equal 1 + 2, tb[:some_int8]
      end

      should "create an instance using #new_alternative_constructor3" do
	tb = Regress::TestBoxed.new_alternative_constructor3 "54"
	assert_instance_of Regress::TestBoxed, tb
	assert_equal 54, tb[:some_int8]
      end

      should "have non-zero positive result for #get_gtype" do
	assert Regress::TestBoxed.get_gtype > 0
      end

      context "an instance" do
	setup do
	  @tb = Regress::TestBoxed.new_alternative_constructor1 123
	end

	should "have a working equals method" do
	  tb2 = Regress::TestBoxed.new_alternative_constructor2 120, 3
	  assert_equal true, @tb.equals(tb2)
	end

	context "its copy method" do
	  setup do
	    @tb2 = @tb.copy
	  end

	  should "return an instance of TestBoxed" do
	    assert_instance_of Regress::TestBoxed, @tb2
	  end

	  should "copy fields" do
	    assert_equal 123, @tb2[:some_int8]
	  end

	  should "create a true copy" do
	    @tb[:some_int8] = 89
	    assert_equal 123, @tb2[:some_int8]
	  end
	end
      end
    end

    context "the Regress::TestEnum type" do
      should "be of type FFI::Enum" do
	assert_instance_of FFI::Enum, Regress::TestEnum
      end
    end

    # TestFlags

    context "the Regress::TestFloating class" do
      context "an instance" do
	setup do
	  @o = Regress::TestFloating.new
	end

	should "have a reference count of 1" do
	  assert_equal 1, ref_count(@o)
	end

	should "have been sunk" do
	  assert !is_floating?(@o)
	end
      end
    end

    context "the Regress::TestObj class" do
      should "create an instance using #new_from_file" do
	o = Regress::TestObj.new_from_file("foo")
	assert_instance_of Regress::TestObj, o
      end

      should "create an instance using #new_callback" do
	o = Regress::TestObj.new_callback Proc.new { }, nil, nil
	assert_instance_of Regress::TestObj, o
      end

      should "have a working #static_method" do
	rv = Regress::TestObj.static_method 623
	assert_equal 623.0, rv
      end

      context "#static_method_callback" do
        should "work when called with a Proc" do
          a = 1
          Regress::TestObj.static_method_callback Proc.new { a = 2 }
          assert_equal 2, a
        end

        should "work when called with nil" do
          assert_nothing_raised do
            Regress::TestObj.static_method_callback nil
          end
        end
      end

      context "an instance" do
	setup do
	  @o = Regress::TestObj.new_from_file("foo")
	end

	should "have a reference count of 1" do
	  assert_equal 1, ref_count(@o)
	end

	should "not float" do
	  assert !is_floating?(@o)
	end

	should "have a working (virtual) #matrix method" do
	  rv = @o.matrix "bar"
	  assert_equal 42, rv
	end

	should "have a working #set_bare method" do
	  obj = Regress::TestObj.new_from_file("bar")
	  rv = @o.set_bare obj
	  # TODO: What is the correct value to retrieve from the fields?
	  assert_equal obj.to_ptr, @o[:bare]
	end

	should "have a working #instance_method method" do
	  rv = @o.instance_method
	  assert_equal(-1, rv)
	end

	should "have a working #torture_signature_0 method" do
	  y, z, q = @o.torture_signature_0(-21, "hello", 13)
	  assert_equal [-21, 2 * -21, "hello".length + 13],
	    [y, z, q]
	end

	context "its #torture_signature_1 method" do
	  should "work for m even" do
	    ret, y, z, q = @o.torture_signature_1(-21, "hello", 12)
	    assert_equal [true, -21, 2 * -21, "hello".length + 12],
	      [ret, y, z, q]
	  end

	  should "throw an exception for m odd" do
	    assert_raises RuntimeError do
	      @o.torture_signature_1(-21, "hello", 11)
	    end
	  end
	end

	should "have a working #instance_method_callback method" do
	  a = 1
	  @o.instance_method_callback Proc.new { a = 2 }
	  assert_equal 2, a
	end

	should "not respond to #static_method" do
	  assert_raises(NoMethodError) { @o.static_method 1 }
	end
      end
    end

    context "the Regress::TestSimpleBoxedA class" do
      should "create an instance using #new" do
	obj = Regress::TestSimpleBoxedA.new
	assert_instance_of Regress::TestSimpleBoxedA, obj
      end

      context "an instance" do
	setup do
	  @obj = Regress::TestSimpleBoxedA.new
	  @obj[:some_int] = 4236
	  @obj[:some_int8] = 36
	  @obj[:some_double] = 23.53
	  @obj[:some_enum] = :value2
	end

	context "its equals method" do
	  setup do
	    @ob2 = Regress::TestSimpleBoxedA.new
	    @ob2[:some_int] = 4236
	    @ob2[:some_int8] = 36
	    @ob2[:some_double] = 23.53
	    @ob2[:some_enum] = :value2
	  end

	  should "return true if values are the same" do
	    assert_equal true, @obj.equals(@ob2)
	  end

	  should "return true if enum values differ" do
	    @ob2[:some_enum] = :value3
	    assert_equal true, @obj.equals(@ob2)
	  end

	  should "return false if other values differ" do
	    @ob2[:some_int] = 1
	    assert_equal false, @obj.equals(@ob2)
	  end
	end

	context "its copy method" do
	  setup do
	    @ob2 = @obj.copy
	  end

	  should "return an instance of TestSimpleBoxedA" do
	    assert_instance_of Regress::TestSimpleBoxedA, @ob2
	  end

	  should "copy fields" do
	    assert_equal 4236, @ob2[:some_int]
	    assert_equal 36, @ob2[:some_int8]
	    assert_equal 23.53, @ob2[:some_double]
	    assert_equal :value2, @ob2[:some_enum]
	  end

	  should "create a true copy" do
	    @obj[:some_int8] = 89
	    assert_equal 36, @ob2[:some_int8]
	  end
	end
      end
    end

    context "the Regress::TestStructA class" do
      context "an instance" do
	should "have a working clone method" do
	  a = Regress::TestStructA.new
	  a[:some_int] = 2556
	  a[:some_int8] = -10
	  a[:some_double] = 1.03455e20
	  a[:some_enum] = :value2

	  b = a.clone

	  assert_equal 2556, b[:some_int]
	  assert_equal(-10, b[:some_int8])
	  assert_equal 1.03455e20, b[:some_double]
	  assert_equal :value2, b[:some_enum]
	end
      end
    end

    # TestStructB
    # TestStructC
    # TestSubObj

    context "the Regress::TestWi8021x class" do
      should "create an instance using #new" do
	o = Regress::TestWi8021x.new
	assert_instance_of Regress::TestWi8021x, o
      end

      should "have a working #static_method" do
	assert_equal(-84, Regress::TestWi8021x.static_method(-42))
      end

      context "an instance" do
	setup do
	  @obj = Regress::TestWi8021x.new
	end

	should "set its boolean struct member with #set_testbool" do
	  @obj.set_testbool true
	  assert_equal 1, @obj[:testbool]
	  @obj.set_testbool false
	  assert_equal 0, @obj[:testbool]
	end

	should "get its boolean struct member with #get_testbool" do
	  @obj[:testbool] = 0
	  assert_equal false, @obj.get_testbool
	  @obj[:testbool] = 1
	  assert_equal true, @obj.get_testbool
	end

	should "get its boolean struct member with #get_property" do
	  @obj[:testbool] = 1
	  gv = GObject::Value.new
	  gv.init GObject.type_from_name "gboolean"
	  @obj.get_property "testbool", gv
	  assert_equal true, gv.get_boolean
	end
      end
    end

    # set_abort_on_error

    context "test_array_fixed_size_int_in" do
      should "return the correct result" do
	assert_equal 5 + 4 + 3 + 2 + 1, Regress.test_array_fixed_size_int_in([5, 4, 3, 2, 1])
      end

      should "raise an error when called with the wrong number of arguments" do
	assert_raises ArgumentError do
	  Regress.test_array_fixed_size_int_in [2]
	end
      end
    end

    should "have correct test_array_fixed_size_int_out" do
      assert_equal [0, 1, 2, 3, 4], Regress.test_array_fixed_size_int_out
    end

    should "have correct test_array_fixed_size_int_return" do
      assert_equal [0, 1, 2, 3, 4], Regress.test_array_fixed_size_int_return
    end

    should "have correct test_array_gint16_in" do
      assert_equal 5 + 4 + 3, Regress.test_array_gint16_in([5, 4, 3])
    end

    should "have correct test_array_gint32_in" do
      assert_equal 5 + 4 + 3, Regress.test_array_gint32_in([5, 4, 3])
    end

    should "have correct test_array_gint64_in" do
      assert_equal 5 + 4 + 3, Regress.test_array_gint64_in([5, 4, 3])
    end

    should "have correct test_array_gint8_in" do
      assert_equal 5 + 4 + 3, Regress.test_array_gint8_in([5, 4, 3])
    end

    should "have correct test_array_gtype_in" do
      t1 = GObject.type_from_name "gboolean"
      t2 = GObject.type_from_name "gint64"
      assert_equal "[gboolean,gint64,]", Regress.test_array_gtype_in([t1, t2])
    end

    should "have correct test_array_int_full_out" do
      assert_equal [0, 1, 2, 3, 4], Regress.test_array_int_full_out
    end

    should "have correct test_array_int_in" do
      assert_equal 5 + 4 + 3, Regress.test_array_int_in([5, 4, 3])
    end

    should "have correct test_array_int_inout" do
      assert_equal [3, 4], Regress.test_array_int_inout([5, 2, 3])
    end

    should "have correct test_array_int_none_out" do
      assert_equal [1, 2, 3, 4, 5], Regress.test_array_int_none_out
    end

    should "have correct test_array_int_null_in" do
      assert_nothing_raised { Regress.test_array_int_null_in nil }
    end

    should "have correct test_array_int_null_out" do
      assert_equal nil, Regress.test_array_int_null_out
    end

    should "have correct test_array_int_out" do
      assert_equal [0, 1, 2, 3, 4], Regress.test_array_int_out
    end

    should "have correct test_async_ready_callback" do
      a = 1

      Regress.test_async_ready_callback Proc.new {
	Gtk.main_quit
	a = 2
      }

      Gtk.main

      assert_equal 2, a
    end

    should "have correct test_boolean" do
      assert_equal false, Regress.test_boolean(false)
      assert_equal true, Regress.test_boolean(true)
    end

    should "have correct test_boolean_false" do
      assert_equal false, Regress.test_boolean_false(false)
    end

    should "have correct test_boolean_true" do
      assert_equal true, Regress.test_boolean_true(true)
    end

    should "have correct test_cairo_context_full_return"
    should "have correct test_cairo_context_none_in"
    should "have correct test_cairo_surface_full_out"
    should "have correct test_cairo_surface_full_return"
    should "have correct test_cairo_surface_none_in"
    should "have correct test_cairo_surface_none_return"

    should "have correct test_callback" do
      result = Regress.test_callback Proc.new { 5 }
      assert_equal 5, result
    end

    should "have correct test_callback_async" do
      a = 1
      Regress.test_callback_async Proc.new {|b|
	a = 2
	b
      }, 44
      r = Regress.test_callback_thaw_async
      assert_equal 44, r
      assert_equal 2, a
    end

    should "have correct test_callback_destroy_notify" do
      a = 1
      r1 = Regress.test_callback_destroy_notify Proc.new {|b|
	a = 2
	b
      }, 42, Proc.new { a = 3 }
      assert_equal 2, a
      assert_equal 42, r1
      r2 = Regress.test_callback_thaw_notifications
      assert_equal 3, a
      assert_equal 42, r2
    end

    context "the test_callback_user_data function" do
      should "return the callbacks return value" do
	result = Regress.test_callback_user_data Proc.new {|u| 5 }, nil
	assert_equal 5, result
      end

      should "handle boolean user_data" do
	a = false
	result = Regress.test_callback_user_data Proc.new {|u|
	  a = u
	  5
	}, true
	assert_equal true, a
      end
    end

    should "have correct test_closure" do
      c = GObject::RubyClosure.new { 5235 }
      r = Regress.test_closure c
      assert_equal 5235, r
    end

    should "have correct test_closure_one_arg" do
      c = GObject::RubyClosure.new { |a| a * 2 }
      r = Regress.test_closure_one_arg c, 2
      assert_equal 4, r
    end

    should "have correct test_double" do
      r = Regress.test_double 5435.32
      assert_equal 5435.32, r
    end

    should "have correct test_enum_param" do
      r = Regress.test_enum_param :value3
      assert_equal "value3", r
    end

    should "have correct test_filename_return"

    should "have correct test_float" do
      r = Regress.test_float 5435.32
      assert_in_delta 5435.32, r, 0.001
    end

    should "have correct test_ghash_container_return"
    should "have correct test_ghash_everything_return"
    should "have correct test_ghash_nested_everything_return"
    should "have correct test_ghash_nested_everything_return2"
    should "have correct test_ghash_nothing_in"
    should "have correct test_ghash_nothing_in2"
    should "have correct test_ghash_nothing_return"
    should "have correct test_ghash_nothing_return2"
    should "have correct test_ghash_null_in"
    should "have correct test_ghash_null_out"
    should "have correct test_ghash_null_return"

    should "have correct test_glist_container_return" do
      arr = Regress.test_glist_container_return
      assert_equal ["1", "2", "3"], arr
    end

    should "have correct test_glist_everything_return" do
      arr = Regress.test_glist_everything_return
      assert_equal ["1", "2", "3"], arr
    end

    should "have correct test_glist_nothing_in" do
      assert_nothing_raised {
        Regress.test_glist_nothing_in ["1", "2", "3"]
      }
    end

    should "have correct test_glist_nothing_in2" do
      assert_nothing_raised {
        Regress.test_glist_nothing_in2 ["1", "2", "3"]
      }
    end

    should "have correct test_glist_nothing_return" do
      arr = Regress.test_glist_nothing_return
      assert_equal ["1", "2", "3"], arr
    end

    should "have correct test_glist_nothing_return2" do
      arr = Regress.test_glist_nothing_return2
      assert_equal ["1", "2", "3"], arr
    end

    should "have correct test_glist_null_in" do
      assert_nothing_raised {
        Regress.test_glist_null_in nil
      }
    end

    should "have correct test_glist_null_out" do
      result = Regress.test_glist_null_out
      assert_equal [], result
    end

    should "have correct test_gslist_container_return" do
      arr = Regress.test_gslist_container_return
      assert_equal ["1", "2", "3"], arr
    end

    should "have correct test_gslist_everything_return" do
      arr = Regress.test_gslist_everything_return
      assert_equal ["1", "2", "3"], arr
    end

    should "have correct test_gslist_nothing_in" do
      assert_nothing_raised {
        Regress.test_gslist_nothing_in ["1", "2", "3"]
      }
    end

    should "have correct test_gslist_nothing_in2" do
      assert_nothing_raised {
        Regress.test_gslist_nothing_in2 ["1", "2", "3"]
      }
    end

    should "have correct test_gslist_nothing_return" do
      arr = Regress.test_gslist_nothing_return
      assert_equal ["1", "2", "3"], arr
    end

    should "have correct test_gslist_nothing_return2" do
      arr = Regress.test_gslist_nothing_return2
      assert_equal ["1", "2", "3"], arr
    end

    should "have correct test_gslist_null_in" do
      assert_nothing_raised {
        Regress.test_gslist_null_in nil
      }
    end

    should "have correct test_gslist_null_out" do
      result = Regress.test_gslist_null_out
      assert_equal [], result
    end

    should "have correct test_gtype" do
      result = Regress.test_gtype 23
      assert_equal 23, result
    end

    should "have correct test_int" do
      result = Regress.test_int 23
      assert_equal 23, result
    end

    should "have correct test_int16" do
      result = Regress.test_int16 23
      assert_equal 23, result
    end

    should "have correct test_int32" do
      result = Regress.test_int32 23
      assert_equal 23, result
    end

    should "have correct test_int64" do
      result = Regress.test_int64 2300000000000
      assert_equal 2300000000000, result
    end

    should "have correct test_int8" do
      result = Regress.test_int8 23
      assert_equal 23, result
    end

    should "have correct test_int_out_utf8" do
      len = Regress.test_int_out_utf8 "How long?"
      assert_equal 9, len
    end

    should "have correct test_int_value_arg" do
      gv = GObject::Value.new
      gv.init GObject.type_from_name "gint"
      gv.set_int 343
      result = Regress.test_int_value_arg gv
      assert_equal 343, result
    end

    should "have correct test_long" do
      result = Regress.test_long 2300000000000
      assert_equal 2300000000000, result
    end

    should "have correct test_multi_callback" do
      a = 1
      result = Regress.test_multi_callback Proc.new {
	a += 1
	23
      }
      assert_equal 2 * 23, result
      assert_equal 3, a
    end

    should "have correct test_multi_double_args" do
      one, two = Regress.test_multi_double_args 23.1
      assert_equal 2 * 23.1, one
      assert_equal 3 * 23.1, two
    end

    should "have correct test_short" do
      result = Regress.test_short 23
      assert_equal 23, result
    end

    should "have correct test_simple_boxed_a_const_return" do
      result = Regress.test_simple_boxed_a_const_return
      assert_equal [5, 6, 7.0], [result[:some_int], result[:some_int8], result[:some_double]]
    end

    context "the test_simple_callback function" do
      should "call the passed-in proc" do
	a = 0
	Regress.test_simple_callback Proc.new { a = 1 }
	assert_equal 1, a
      end

      # XXX: The scope data does not seem to be reliable enough.
      if false
      should "not store the proc in CALLBACKS" do
	n = Regress::Lib::CALLBACKS.length
	Regress.test_simple_callback Proc.new { }
	assert_equal n, Regress::Lib::CALLBACKS.length
      end
      end
    end

    should "have correct test_size" do
      assert_equal 2354, Regress.test_size(2354)
    end

    should "have correct test_ssize" do
      assert_equal(-2_000_000, Regress.test_ssize(-2_000_000))
    end

    should "have correct test_strv_in" do
      assert_equal true, Regress.test_strv_in(['1', '2', '3'])
    end

    should "have correct test_strv_out"
    should "have correct test_strv_out_c"
    should "have correct test_strv_out_container"
    should "have correct test_strv_outarg"

    should "have correct test_timet" do
      # Time rounded to seconds.
      t = Time.at(Time.now.to_i)
      result = Regress.test_timet(t.to_i)
      assert_equal t, Time.at(result)
    end

    should "have correct test_torture_signature_0" do
      y, z, q = Regress.test_torture_signature_0 86, "foo", 2
      assert_equal [86, 2*86, 3+2], [y, z, q]
    end

    context "its #test_torture_signature_1 method" do
      should "work for m even" do
	ret, y, z, q = Regress.test_torture_signature_1(-21, "hello", 12)
	assert_equal [true, -21, 2 * -21, "hello".length + 12], [ret, y, z, q]
      end

      should "throw an exception for m odd" do
	assert_raises RuntimeError do
	  Regress.test_torture_signature_1(-21, "hello", 11)
	end
      end
    end
      
    should "have correct test_torture_signature_2" do
      a = 1
      y, z, q = Regress.test_torture_signature_2 244,
	Proc.new {|u| a = u }, 2, Proc.new { a = 3 },
	"foofoo", 31
      assert_equal [244, 2*244, 6+31], [y, z, q]
      assert_equal 3, a
    end

    should "have correct test_uint" do
      assert_equal 31, Regress.test_uint(31)
    end

    should "have correct test_uint16" do
      assert_equal 31, Regress.test_uint16(31)
    end

    should "have correct test_uint32" do
      assert_equal 540000, Regress.test_uint32(540000)
    end

    should "have correct test_uint64" do
      assert_equal 54_000_000_000_000, Regress.test_uint64(54_000_000_000_000)
    end

    should "have correct test_uint8" do
      assert_equal 31, Regress.test_uint8(31)
    end

    should "have correct test_ulong" do
      assert_equal 54_000_000_000_000, Regress.test_uint64(54_000_000_000_000)
    end

    should "have correct test_ushort" do
      assert_equal 54_000_000, Regress.test_uint64(54_000_000)
    end

    should "have correct test_utf8_const_in" do
      # TODO: Capture stderr to automatically look for error messages.
      assert_nothing_raised do
	Regress.test_utf8_const_in("const \xe2\x99\xa5 utf8")
      end
    end

    should "have correct test_utf8_const_return" do
      result = Regress.test_utf8_const_return
      assert_equal "const \xe2\x99\xa5 utf8", result
    end

    should "have correct test_utf8_inout" do
      result = Regress.test_utf8_inout "const \xe2\x99\xa5 utf8"
      assert_equal "nonconst \xe2\x99\xa5 utf8", result
    end

    should "have correct test_utf8_nonconst_return" do
      result = Regress.test_utf8_nonconst_return
      assert_equal "nonconst \xe2\x99\xa5 utf8", result
    end

    should "have correct test_utf8_null_in" do
      assert_nothing_raised do
	Regress.test_utf8_null_in nil
      end
    end

    should "have correct test_utf8_null_out" do
      assert_equal nil, Regress.test_utf8_null_out
    end

    should "have correct test_utf8_out" do
      result = Regress.test_utf8_out
      assert_equal "nonconst \xe2\x99\xa5 utf8", result
    end

    should "have correct test_utf8_out_nonconst_return" do
      r, out = Regress.test_utf8_out_nonconst_return
      assert_equal ["first", "second"], [r, out]
    end

    should "have correct test_utf8_out_out" do
      out0, out1 = Regress.test_utf8_out_nonconst_return
      assert_equal ["first", "second"], [out0, out1]
    end

    should "have correct test_value_return" do
      result = Regress.test_value_return 3423
      assert_equal 3423, result.get_int
    end

  end

end