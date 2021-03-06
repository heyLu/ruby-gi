require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class FunctionDefinitionBuilderTest < MiniTest::Spec
  context "The Builder::Function class" do
    should "build correct definition of Gtk.init" do
      go = get_function_introspection_data 'Gtk', 'init'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected = "
	def init argv
	  argc = argv.length
	  _v1 = GirFFI::ArgHelper.gint32_to_inoutptr argc
	  _v3 = GirFFI::ArgHelper.utf8_array_to_inoutptr argv
	  ::Lib.gtk_init _v1, _v3
	  _v2 = GirFFI::ArgHelper.outptr_to_gint32 _v1
	  GirFFI::ArgHelper.cleanup_ptr _v1
	  _v4 = GirFFI::ArgHelper.outptr_to_utf8_array _v3, _v2
	  GirFFI::ArgHelper.cleanup_ptr_array_ptr _v3, _v2
	  return _v4
	end
      "

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Gtk::Widget.show" do
      go = get_method_introspection_data 'Gtk', 'Widget', 'show'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected = "
	def show
	  ::Lib.gtk_widget_show self
	end
      "

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Regress.test_callback_destroy_notify" do
      go = get_function_introspection_data 'Regress', 'test_callback_destroy_notify'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected =
	"def test_callback_destroy_notify callback, user_data, notify
	  _v1 = GirFFI::ArgHelper.wrap_in_callback_args_mapper \"Regress\", \"TestCallbackUserData\", callback
	  ::Lib::CALLBACKS << _v1
	  _v2 = GirFFI::ArgHelper.object_to_inptr user_data
	  _v3 = GirFFI::ArgHelper.wrap_in_callback_args_mapper \"GLib\", \"DestroyNotify\", notify
	  ::Lib::CALLBACKS << _v3
	  _v4 = ::Lib.regress_test_callback_destroy_notify _v1, _v2, _v3
	  return _v4
	end"

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Regress::TestObj#new_from_file" do
      go = get_method_introspection_data 'Regress', 'TestObj', 'new_from_file'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected =
	"def new_from_file x
	  _v1 = GirFFI::ArgHelper.utf8_to_inptr x
	  _v4 = FFI::MemoryPointer.new(:pointer).write_pointer nil
	  _v2 = ::Lib.regress_test_obj_new_from_file _v1, _v4
	  GirFFI::ArgHelper.check_error(_v4)
	  _v3 = self.constructor_wrap(_v2)
	  return _v3
	end"

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Regress:test_array_int_null_in" do
      go = get_function_introspection_data 'Regress', 'test_array_int_null_in'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected =
	"def test_array_int_null_in arr
	  _v1 = GirFFI::ArgHelper.gint32_array_to_inptr arr
	  len = arr.nil? ? 0 : arr.length
	  _v2 = len
	  ::Lib.regress_test_array_int_null_in _v1, _v2
	  GirFFI::ArgHelper.cleanup_ptr _v1
	end"

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Regress:test_array_int_null_out" do
      go = get_function_introspection_data 'Regress', 'test_array_int_null_out'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected =
	"def test_array_int_null_out
	  _v1 = GirFFI::ArgHelper.pointer_outptr
	  _v3 = GirFFI::ArgHelper.gint32_outptr
	  ::Lib.regress_test_array_int_null_out _v1, _v3
	  _v4 = GirFFI::ArgHelper.outptr_to_gint32 _v3
	  GirFFI::ArgHelper.cleanup_ptr _v3
	  _v2 = GirFFI::ArgHelper.outptr_to_gint32_array _v1, _v4
	  GirFFI::ArgHelper.cleanup_ptr_ptr _v1
	  return _v2
	end"

      assert_equal cws(expected), cws(code)
    end

    it "builds the correct definition of GIMarshallingTests::Object#method_array_inout" do
      go = get_method_introspection_data 'GIMarshallingTests', 'Object', 'method_array_inout'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected =
        "def method_array_inout ints
          _v1 = GirFFI::ArgHelper.gint32_array_to_inoutptr ints
          length = ints.length
          _v3 = GirFFI::ArgHelper.gint32_to_inoutptr length
          ::Lib.gi_marshalling_tests_object_method_array_inout self, _v1, _v3
          _v4 = GirFFI::ArgHelper.outptr_to_gint32 _v3
          GirFFI::ArgHelper.cleanup_ptr _v3
          _v2 = GirFFI::ArgHelper.outptr_to_gint32_array _v1, _v4
          GirFFI::ArgHelper.cleanup_ptr _v1
          return _v2
	end"

      assert_equal cws(expected), cws(code)
    end

  end
end
