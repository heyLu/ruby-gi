require 'gir_ffi/allocation_helper'

module GirFFI
  module ArgHelper
    def self.object_to_inptr obj
      return obj.to_ptr if obj.respond_to? :to_ptr
      return nil if obj.nil?
      FFI::Pointer.new(obj.object_id)
    end

    def self.typed_array_to_inptr type, ary
      return nil if ary.nil?
      block = allocate_array_of_type type, ary.length
      block.send "put_array_of_#{type}", 0, ary
    end

    def self.int32_array_to_inptr ary
      typed_array_to_inptr :int32, ary
    end

    # TODO: Use alias.
    def self.int_array_to_inptr ary
      int32_array_to_inptr ary
    end

    def self.int16_array_to_inptr ary
      typed_array_to_inptr :int16, ary
    end

    def self.int64_array_to_inptr ary
      typed_array_to_inptr :int64, ary
    end

    def self.int8_array_to_inptr ary
      typed_array_to_inptr :int8, ary
    end

    def self.utf8_to_inptr str
      return nil if str.nil?
      len = str.bytesize
      AllocationHelper.safe_malloc(len + 1).write_string(str).put_char(len, 0)
    end

    def self.gtype_array_to_inptr ary
      case FFI.type_size(:size_t)
      when 4
	int32_array_to_inptr ary
      when 8
	int64_array_to_inptr ary
      else
	raise RuntimeError, "Unexpected size of :size_t"
      end
    end

    def self.cleanup_ptr ptr
      LibC.free ptr
    end

    def self.cleanup_ptr_ptr ptr
      block = ptr.read_pointer
      LibC.free ptr
      LibC.free block
    end

    # Takes an outptr to a pointer array, and frees all pointers.
    def self.cleanup_ptr_array_ptr ptr, size
      return if ptr.nil?

      block = ptr.read_pointer
      LibC.free ptr

      return if block.null?

      ptrs = block.read_array_of_pointer(size)
      LibC.free block

      ptrs.map do |p|
	LibC.free p unless p.null?
      end
    end

    def self.int_to_inoutptr val
      int_pointer.write_int val
    end

    def self.utf8_to_inoutptr str
      sptr = utf8_to_inptr str
      pointer_pointer.write_pointer sptr
    end

    def self.int_array_to_inoutptr ary
      block = int_array_to_inptr ary
      pointer_pointer.write_pointer block
    end

    def self.utf8_array_to_inoutptr ary
      return nil if ary.nil?

      ptrs = ary.map {|str| utf8_to_inptr str}

      block = AllocationHelper.safe_malloc FFI.type_size(:pointer) * ptrs.length
      block.write_array_of_pointer ptrs

      pointer_pointer.write_pointer block
    end

    def self.double_to_inoutptr val
      double_pointer.put_double 0, val
    end

    def self.int_pointer
      AllocationHelper.safe_malloc FFI.type_size(:int)
    end

    def self.double_pointer
      AllocationHelper.safe_malloc FFI.type_size(:double)
    end

    def self.pointer_pointer
      AllocationHelper.safe_malloc FFI.type_size(:pointer)
    end

    def self.int_outptr
      int_pointer.write_int 0
    end

    def self.double_outptr
      double_pointer.write_double 0.0
    end

    def self.pointer_outptr
      pointer_pointer.write_pointer nil
    end

    def self.utf8_outptr
      pointer_outptr
    end

    # Converts an outptr to a pointer.
    def self.outptr_to_pointer ptr
      ptr.read_pointer
    end

    # Converts an outptr to an int.
    def self.outptr_to_int ptr
      ptr.read_int
    end

    # Converts an outptr to a string.
    def self.outptr_to_utf8 ptr
      ptr_to_utf8 ptr.read_pointer
    end

    # Converts an outptr to a string array.
    def self.outptr_to_utf8_array ptr, size
      block = ptr.read_pointer
      return nil if block.null?
      ptrs = block.read_array_of_pointer(size)

      ptrs.map { |p| ptr_to_utf8 p }
    end

    # Converts an outptr to a double.
    def self.outptr_to_double ptr
      ptr.get_double 0
    end

    # Converts an outptr to an array of int.
    def self.outptr_to_int_array ptr, size
      block = ptr.read_pointer
      return nil if block.null?
      ptr_to_int_array block, size
    end

    def self.ptr_to_int_array ptr, size
      ptr.read_array_of_int(size)
    end

    def self.ptr_to_utf8 ptr
      ptr.null? ? nil : ptr.read_string
    end

    def self.wrap_in_callback_args_mapper namespace, name, prc
      return prc if FFI::Function === prc
      info = gir.find_by_name namespace, name
      return Proc.new do |*args|
	prc.call *map_callback_args(args, info)
      end
    end

    def self.map_callback_args args, info
      args.zip(info.args).map { |arg, inf|
	map_single_callback_arg arg, inf }
    end

    def self.map_single_callback_arg arg, info
      type = info.type
      tag = type.tag

      case tag
      when :interface
	iface = type.interface
	if iface.type == :object
	  object_pointer_to_object arg
	else
	  arg
	end
      when :utf8
	ptr_to_utf8 arg
      when :void
	if arg.null?
	  nil
	else
	  begin
	    ObjectSpace._id2ref arg.address
	  rescue RangeError
	    arg
	  end
	end
      else
	arg
      end
    end

    def self.check_error errpp
      errp = errpp.read_pointer
      raise GError.new(errp)[:message] unless errp.null?
    end

    def self.sink_if_floating gobject
      if GirFFI::GObject.object_is_floating(gobject)
	GirFFI::GObject.object_ref_sink(gobject)
      end
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
	tpname = ::GObject.type_name tp
	raise RuntimeError, "Unable to find info for type '#{tpname}' (#{tp})"
      end

      klass = GirFFI::Builder.build_class info.namespace, info.name
      klass.wrap optr
    end

    def self.gir
      gir = GirFFI::IRepository.default
    end
  end
end
