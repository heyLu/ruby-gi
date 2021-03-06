require 'gir_ffi/allocation_helper'
require 'gir_ffi/builder'
require 'gir_ffi/builder/dynamic_type'

module GirFFI
  module ArgHelper
    SIMPLE_G_TYPES = [
      :gint8, :gint16, :gint, :gint32, :gint64,
      :guint8, :guint16, :guint32, :guint64,
      :gfloat, :gdouble]

    def self.setup_array_to_inptr_handler_for *types
      types.flatten.each do |type|
        ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type
        defn =
          "def self.#{type}_array_to_inptr ary
            return nil if ary.nil?
            block = allocate_array_of_type #{ffi_type.inspect}, ary.length
            block.put_array_of_#{ffi_type} 0, ary
          end"
        eval defn
      end
    end

    setup_array_to_inptr_handler_for SIMPLE_G_TYPES
    setup_array_to_inptr_handler_for :pointer

    # FIXME: Hideous.
    def self.object_to_inptr obj
      return obj.to_ptr if obj.respond_to? :to_ptr
      return nil if obj.nil?
      return obj if obj.is_a? FFI::Pointer
      FFI::Pointer.new(obj.object_id)
    end

    def self.typed_array_to_inptr type, ary
      return nil if ary.nil?
      return utf8_array_to_inptr ary if type == :utf8
      block = allocate_array_of_type type, ary.length
      block.send "put_array_of_#{type}", 0, ary
    end

    def self.utf8_to_inptr str
      return nil if str.nil?
      len = str.bytesize
      AllocationHelper.safe_malloc(len + 1).write_string(str).put_char(len, 0)
    end

    def self.utf8_array_to_inptr ary
      return nil if ary.nil?
      ptr_ary = ary.map {|str| utf8_to_inptr str}
      ptr_ary << nil
      typed_array_to_inptr :pointer, ptr_ary
    end

    # FIXME: :interface is too generic. implement only GValueArray?
    def self.interface_array_to_inptr ary
      return nil if ary.nil?
      raise NotImplementedError
    end

    def self.interface_pointer_array_to_inptr ary
      return nil if ary.nil?
      ptr_ary = ary.map {|ifc| ifc.to_ptr}
      ptr_ary << nil
      pointer_array_to_inptr ptr_ary
    end

    def self.cleanup_ptr ptr
      LibC.free ptr
    end

    def self.cleanup_ptr_ptr ptr
      LibC.free ptr.read_pointer
      LibC.free ptr
    end

    # Takes an outptr to a pointer array, and frees all pointers.
    def self.cleanup_ptr_array_ptr ptr, size
      block = ptr.read_pointer
      unless block.null?
        block.read_array_of_pointer(size).each { |pt| LibC.free pt }
        LibC.free block
      end
      LibC.free ptr
    end

    def self.setup_type_to_inoutptr_handler_for *types
      types.flatten.each do |type|
        ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type
        defn =
          "def self.#{type}_to_inoutptr val
            #{type}_pointer.put_#{ffi_type} 0, val
          end"
        eval defn
      end
    end

    setup_type_to_inoutptr_handler_for SIMPLE_G_TYPES
    setup_type_to_inoutptr_handler_for :pointer

    def self.gboolean_to_inoutptr val
      gboolean_pointer.put_int 0, (val ? 1 : 0)
    end

    def self.utf8_to_inoutptr str
      sptr = utf8_to_inptr str
      pointer_pointer.write_pointer sptr
    end

    def self.int32_array_to_inoutptr ary
      block = gint32_array_to_inptr ary
      pointer_pointer.write_pointer block
    end

    def self.utf8_array_to_inoutptr ary
      return nil if ary.nil?
      pointer_pointer.write_pointer utf8_array_to_inptr(ary)
    end

    class << self
      alias int_array_to_inoutptr int32_array_to_inoutptr
      alias gint32_array_to_inoutptr int32_array_to_inoutptr
    end

    def self.setup_pointer_maker_for *types
      types.flatten.each do |type|
        ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type
        size = FFI.type_size ffi_type
        defn =
          "def self.#{type}_pointer
            AllocationHelper.safe_malloc #{size}
          end"
        eval defn
      end
    end

    setup_pointer_maker_for SIMPLE_G_TYPES
    setup_pointer_maker_for :pointer

    class << self
      alias gboolean_pointer gint_pointer
    end

    def self.setup_type_outptr_handler_for *types
      types.flatten.each do |type|
        ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type
        defn =
          "def self.#{type}_outptr
            #{type}_pointer.put_#{ffi_type} 0, 0
          end"
        eval defn
      end
    end

    setup_type_outptr_handler_for SIMPLE_G_TYPES

    def self.gboolean_outptr
      gboolean_pointer.put_int 0, 0
    end

    def self.pointer_outptr
      pointer_pointer.put_pointer 0, nil
    end

    def self.utf8_outptr
      pointer_outptr
    end

    def self.setup_outptr_to_type_handler_for *types
      types.flatten.each do |type|
        ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type
        defn =
          "def self.outptr_to_#{type} ptr
            ptr.get_#{ffi_type} 0
          end"
        eval defn
      end
    end

    setup_outptr_to_type_handler_for SIMPLE_G_TYPES
    setup_outptr_to_type_handler_for :pointer

    # Converts an outptr to a boolean.
    def self.outptr_to_gboolean ptr
      (ptr.get_int 0) != 0
    end

    # Converts an outptr to a string.
    def self.outptr_to_utf8 ptr
      ptr_to_utf8 ptr.read_pointer
    end

    # Converts an outptr to a string array.
    def self.outptr_to_utf8_array ptr, size
      block = ptr.read_pointer
      return nil if block.null?
      ptr_to_utf8_array block, size
    end

    # Converts an outptr to an array of int.
    def self.outptr_to_int32_array ptr, size
      block = ptr.read_pointer
      return nil if block.null?
      ptr_to_gint32_array block, size
    end

    # Converts an outptr to an array of the given class.
    def self.outptr_to_interface_array klass, ptr, size
      block = ptr.read_pointer
      return nil if block.null?
      ptr_to_interface_array klass, block, size
    end

    class << self
      alias outptr_to_int_array outptr_to_int32_array
      alias outptr_to_gint32_array outptr_to_int32_array
    end

    def self.ptr_to_typed_array type, ptr, size
      if type == :utf8
        ptr_to_utf8_array ptr, size
      else
        ptr.send "get_array_of_#{type}", 0, size
      end
    end

    def self.setup_ptr_to_type_array_handler_for *types
      types.flatten.each do |type|
        ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type
        defn =
          "def self.ptr_to_#{type}_array ptr, size
            ptr.get_array_of_#{ffi_type}(0, size)
          end"
        eval defn
      end
    end

    setup_ptr_to_type_array_handler_for SIMPLE_G_TYPES

    def self.ptr_to_utf8_array ptr, size
      ptrs = ptr.read_array_of_pointer(size)

      ptrs.map { |ptr| ptr_to_utf8 ptr }
    end

    def self.ptr_to_interface_array klass, ptr, size
      sz = klass.ffi_structure.size
      arr = []
      size.times do
        arr << klass.wrap(ptr)
        ptr += sz
      end
      arr
    end

    if RUBY_VERSION < "1.9"
      def self.ptr_to_utf8 ptr
        ptr.null? ? nil : ptr.read_string
      end
    else
      def self.ptr_to_utf8 ptr
        ptr.null? ? nil : ptr.read_string.force_encoding("utf-8")
      end
    end

    def self.ptr_to_utf8_length ptr, len
      ptr.null? ? nil : ptr.read_string(len)
    end

    # Set up gtype handlers depending on type size.
    class << self
      sz = FFI.type_size(:size_t) * 8
      type = "guint#{sz}"
      alias_method :gtype_array_to_inptr, "#{type}_array_to_inptr"
      alias_method :gtype_outptr, "#{type}_outptr"
      alias_method :gtype_to_inoutptr, "#{type}_to_inoutptr"
      alias_method :outptr_to_gtype, "outptr_to_#{type}"
      alias_method :ptr_to_gtype_array, "ptr_to_#{type}_array"
    end

    def self.outptr_strv_to_utf8_array ptr
      strv_to_utf8_array ptr.read_pointer
    end

    def self.strv_to_utf8_array strv
      return [] if strv.null?
      arr = []
      i = 0
      loop do
        ptr = strv.get_pointer i * FFI.type_size(:pointer)
        break if ptr.null?
        arr << ptr.read_string
        i += 1
      end
      return arr
    end

    def self.utf8_array_to_glist arr
      return nil if arr.nil?
      arr.inject(GLib.list_new :utf8) { |lst, str|
        GLib.list_append lst, utf8_to_inptr(str) }
    end

    def self.gint32_array_to_glist arr
      return nil if arr.nil?
      arr.inject(GLib.list_new :gint32) { |lst, int|
        GLib.list_append lst, cast_int32_to_pointer(int) }
    end

    def self.utf8_array_to_gslist arr
      return nil if arr.nil?
      arr.reverse.inject(GLib.slist_new :utf8) { |lst, str|
        GLib.slist_prepend lst, utf8_to_inptr(str) }
    end

    def self.gint32_array_to_gslist arr
      return nil if arr.nil?
      arr.reverse.inject(GLib.slist_new :gint32) { |lst, int|
        GLib.slist_prepend lst, cast_int32_to_pointer(int) }
    end

    def self.hash_to_ghash keytype, valtype, hash
      return nil if hash.nil?
      ghash = GLib.hash_table_new keytype, valtype
      hash.each do |key, val|
        ghash.insert key, val
      end
      ghash
    end

    def self.void_array_to_gslist ary
      return nil if ary.nil?
      return ary if ary.is_a? GLib::SList
      raise NotImplementedError
    end

    def self.glist_to_utf8_array ptr
      return [] if ptr.null?
      # FIXME: Quasi-circular dependency on generated module
      list = GLib::List.wrap(ptr)
      str = ptr_to_utf8(list[:data])
      [str] + glist_to_utf8_array(list[:next])
    end

    def self.gslist_to_utf8_array ptr
      return [] if ptr.null?
      # FIXME: Quasi-circular dependency on generated module
      list = GLib::SList.wrap(ptr)
      str = ptr_to_utf8(list[:data])
      [str] + gslist_to_utf8_array(list[:next])
    end

    def self.outgslist_to_utf8_array ptr
      gslist_to_utf8_array ptr.read_pointer
    end

    def self.wrap_in_callback_args_mapper namespace, name, prc
      return prc if FFI::Function === prc
      return nil if prc.nil?
      info = gir.find_by_name namespace, name
      return Proc.new do |*args|
	prc.call(*map_callback_args(args, info))
      end
    end

    def self.map_callback_args args, info
      args.zip(info.args).map { |arg, inf|
	map_single_callback_arg arg, inf }
    end

    # TODO: Use GirFFI::ReturnValue classes for mapping.
    def self.map_single_callback_arg arg, info
      case info.argument_type.tag
      when :interface
        map_interface_callback_arg arg, info
      when :utf8
	ptr_to_utf8 arg
      when :void
        map_void_callback_arg arg
      else
	arg
      end
    end

    def self.map_interface_callback_arg arg, info
      iface = info.argument_type.interface
      case iface.info_type
      when :object
        object_pointer_to_object arg
      when :struct
        klass = GirFFI::Builder.build_class iface
        klass.wrap arg
      else
        arg
      end
    end

    def self.map_void_callback_arg arg
      if arg.null?
        nil
      else
        begin
          # TODO: Use custom object store.
          ObjectSpace._id2ref arg.address
        rescue RangeError
          arg
        end
      end
    end

    def self.check_error errpp
      errp = errpp.read_pointer
      raise GError.new(errp)[:message] unless errp.null?
    end

    def self.check_fixed_array_size size, arr, name
      unless arr.size == size
	raise ArgumentError, "#{name} should have size #{size}"
      end
    end

    def self.allocate_array_of_type type, length
      AllocationHelper.safe_malloc FFI.type_size(type) * length
    end

    # FIXME: Quasi-circular dependency on generated module
    def self.object_pointer_to_object optr
      return nil if optr.null?
      tp = ::GObject.type_from_instance_pointer optr
      info = gir.find_by_gtype tp
      if info.nil?
        klass = GirFFI::Builder::DynamicType.new(tp).build_class
      else
        klass = GirFFI::Builder.build_class info
      end
      klass.wrap optr
    end

    def self.gir
      gir = GirFFI::IRepository.default
    end

    def self.cast_from_pointer type, it
      case type
      when :utf8, :filename
        ptr_to_utf8 it
      when :gint32
        cast_pointer_to_int32 it
      else
        it.address
      end
    end

    def self.cast_uint32_to_int32 val
      if val >= 0x80000000
        -(0x100000000-val)
      else
        val
      end
    end

    def self.cast_pointer_to_int32 ptr
      cast_uint32_to_int32(ptr.address & 0xffffffff)
    end

    def self.cast_int32_to_pointer int
      FFI::Pointer.new(int)
    end
  end
end
