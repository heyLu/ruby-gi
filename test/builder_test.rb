require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'girffi/builder'

class BuilderTest < Test::Unit::TestCase
  context "The GirFFI::Builder module" do
    # TODO: Use gir's sample Everything library for testing instead.
    context "building GObject::Object" do
      setup do
	GirFFI::Builder.build_class 'GObject', 'Object', 'NS1'
      end

      should "create a method_missing method for the class" do
	ms = NS1::GObject::Object.instance_methods(false)
	assert_contains ms, "method_missing"
      end

      should "create a Lib module in the parent namespace ready to attach functions from gobject-2.0" do
	gir = GIRepository::IRepository.default
	expected = gir.shared_library 'GObject'
	assert_same_elements [*expected], NS1::GObject::Lib.ffi_libraries.map(&:name)
      end

      should "create an array CALLBACKS inside the GObject::Lib module" do
	assert_equal [], NS1::GObject::Lib::CALLBACKS
      end

      should "not replace existing classes" do
	oldclass = NS1::GObject::Object
	GirFFI::Builder.build_class 'GObject', 'Object', 'NS1'
	assert_equal oldclass, NS1::GObject::Object
      end
    end

    context "building Gtk::Window" do
      setup do
	GirFFI::Builder.build_class 'Gtk', 'Window', 'NS3'
      end

      should "build parent classes also" do
	assert NS3::Gtk.const_defined? :Widget
	assert NS3::Gtk.const_defined? :Object
	assert NS3.const_defined? :GObject
	assert NS3::GObject.const_defined? :InitiallyUnowned
	assert NS3::GObject.const_defined? :Object
      end

      should "set up inheritence chain" do
	assert_equal [
	  NS3::Gtk::Window,
	  NS3::Gtk::Bin,
	  NS3::Gtk::Container,
	  NS3::Gtk::Widget,
	  NS3::Gtk::Object,
	  NS3::GObject::InitiallyUnowned,
	  NS3::GObject::Object,
	  Object
	], NS3::Gtk::Window.ancestors[0..7]
      end

      should "create a Gtk::Window#to_ptr method" do
	assert NS3::Gtk::Window.instance_methods.include? "to_ptr"
      end

      should "attach gtk_window_new to Gtk::Lib" do
	assert NS3::Gtk::Lib.respond_to? :gtk_window_new
      end

      should "result in Gtk::Window.new to succeed" do
	assert_nothing_raised {NS3::Gtk::Window.new(:toplevel)}
      end
    end

    context "building Gtk" do
      setup do
	GirFFI::Builder.build_module 'Gtk', 'NS2'
      end

      # TODO: Should also create a const_missing method to autocreate all
      # the classes in that namespace.
      should "create a method_missing method for the module" do
	assert_contains NS2::Gtk.public_methods - Module.public_methods, "method_missing"
      end

      should "create a Lib module ready to attach functions from gtk-x11-2.0" do
	# The Gtk module has more than one library on my current machine.
	gir = GIRepository::IRepository.default
	expected = (gir.shared_library 'Gtk').split(',')
	assert_same_elements expected, NS2::Gtk::Lib.ffi_libraries.map(&:name)
      end

      should "create an array CALLBACKS inside the Gtk::Lib module" do
	assert_equal [], NS2::Gtk::Lib::CALLBACKS
      end

      should "not replace existing module" do
	oldmodule = NS2::Gtk
	GirFFI::Builder.build_module 'Gtk', 'NS2'
	assert_equal oldmodule, NS2::Gtk
      end

      should "not replace existing Lib module" do
	oldmodule = NS2::Gtk::Lib
	GirFFI::Builder.build_module 'Gtk', 'NS2'
	assert_equal oldmodule, NS2::Gtk::Lib
      end
    end

    context "looking at Gtk.main" do
      setup do
	@go = GirFFI::Builder.function_introspection_data 'Gtk', 'main'
      end
      # TODO: function_introspection_data should not return introspection data if not a function.
      should "have correct introspection data" do
	gir = GIRepository::IRepository.default
	gir.require "Gtk", nil
	go2 = gir.find_by_name "Gtk", "main"
	assert_equal go2, @go
      end

      should "build correct definition of Gtk.main" do
	code = GirFFI::Builder.function_definition @go, Lib

	expected = "def main\nLib.gtk_main\nend"

	assert_equal cws(expected), cws(code)
      end

      should "attach function to Whatever::Lib" do
	mod = Module.new
	mod.const_set :Lib, libmod = Module.new
	libmod.module_eval do
	  extend FFI::Library
	  ffi_lib "gtk-x11-2.0"
	end

	GirFFI::Builder.attach_ffi_function libmod, @go
	assert_contains libmod.public_methods, "gtk_main"
      end
    end

    context "looking at Gtk.init" do
      setup do
	@go = GirFFI::Builder.function_introspection_data 'Gtk', 'init'
      end

      should "build correct definition of Gtk.init" do
	code = GirFFI::Builder.function_definition @go, Lib

	expected =
	  "def init argc, argv
	    _v1 = GirFFI::ArgHelper.int_to_inoutptr argc
	    _v3 = GirFFI::ArgHelper.string_array_to_inoutptr argv
	    Lib.gtk_init _v1, _v3
	    _v2 = GirFFI::ArgHelper.outptr_to_int _v1
	    _v4 = GirFFI::ArgHelper.outptr_to_string_array _v3, argv.nil? ? 0 : argv.size
	    return _v2, _v4
	  end"

	assert_equal cws(expected), cws(code)
      end

      should "have :pointer, :pointer as types of the arguments for the attached function" do
	# FIXME: Ideally, we attach the function and test that it requires
	# the correct argument types.
	assert_equal [:pointer, :pointer], GirFFI::Builder.ffi_function_argument_types(@go)
      end

      should "have :void as return type for the attached function" do
	assert_equal :void, GirFFI::Builder.ffi_function_return_type(@go)
      end
    end

    context "looking at Gtk::Widget#show" do
      setup do
	@go = GirFFI::Builder.method_introspection_data 'Gtk', 'Widget', 'show'
      end

      should "build correct definition of Gtk::Widget.show" do
	code = GirFFI::Builder.function_definition @go, Lib

	expected =
	  "def show
	    Lib.gtk_widget_show @gobj
	  end"

	assert_equal cws(expected), cws(code)
      end

      should "have :pointer as types of the arguments for the attached function" do
	assert_equal [:pointer], GirFFI::Builder.ffi_function_argument_types(@go)
      end

    end

    context "looking at GObject.signal_connect_data" do
      setup do
	@go = GirFFI::Builder.function_introspection_data 'GObject', 'signal_connect_data'
      end

      # TODO: This is essentially the same test as for
      # FunctionDefinitionBuilder. Test this only once.
      should "build the correct definition" do
	code = GirFFI::Builder.function_definition @go, Lib

	expected =
	  "def signal_connect_data instance, detailed_signal, c_handler, data, destroy_data, connect_flags
	    _v1 = GirFFI::ArgHelper.object_to_inptr instance
	    Lib::CALLBACKS << c_handler
	    _v2 = GirFFI::ArgHelper.object_to_inptr data
	    Lib::CALLBACKS << destroy_data
	    Lib.g_signal_connect_data _v1, detailed_signal, c_handler, _v2, destroy_data, connect_flags
	  end"

	assert_equal cws(expected), cws(code)
      end

      should "have the correct types of the arguments for the attached function" do
	assert_equal [:pointer, :string, :Callback, :pointer, :ClosureNotify, :ConnectFlags],
	  GirFFI::Builder.ffi_function_argument_types(@go)
      end

      should "define ffi callback types :Callback and :ClosureNotify" do
	lb = Module.new
	lb.extend FFI::Library

	assert_raises(TypeError) { lb.find_type :Callback }
	assert_raises(TypeError) { lb.find_type :ClosureNotify }

	GirFFI::Builder.define_ffi_types lb, @go

	cb = lb.find_type :Callback
	cn = lb.find_type :ClosureNotify

	assert_equal FFI.find_type(:void), cb.result_type
	assert_equal FFI.find_type(:void), cn.result_type
	assert_equal [], cb.param_types
	assert_equal [FFI.find_type(:pointer), FFI.find_type(:pointer)], cn.param_types
      end

      should "define ffi enum type :ConnectFlags" do
	lb = Module.new
	lb.extend FFI::Library
	GirFFI::Builder.define_ffi_types lb, @go
	assert_equal({:after => 1, :swapped => 2}, lb.find_type(:ConnectFlags).to_h)
      end
    end

    context "setting up Everything::TestBoxed" do
      setup do
	GirFFI::Builder.build_class 'Everything', 'TestBoxed'
      end

      should "set up #_real_new as an alias to #new" do
	assert Everything::TestBoxed.respond_to? "_real_new"
      end

      should "allow creation using #new" do
	tb = Everything::TestBoxed.new
	assert_instance_of Everything::TestBoxed, tb
      end

      should "allow creation using alternative constructors" do
	tb = Everything::TestBoxed.new_alternative_constructor1 1
	assert_instance_of Everything::TestBoxed, tb
	tb = Everything::TestBoxed.new_alternative_constructor2 1, 2
	assert_instance_of Everything::TestBoxed, tb
	tb = Everything::TestBoxed.new_alternative_constructor3 "hello"
	assert_instance_of Everything::TestBoxed, tb
      end
    end

    # TODO: Should not allow functions to be called as methods, etc.

    context "looking at Everything's functions" do
      setup do
	GirFFI::Builder.build_module 'Everything'
      end
      should "correctly handle test_boolean" do
	assert_equal false, Everything.test_boolean(false)
	assert_equal true, Everything.test_boolean(true)
      end
    end
  end
end
