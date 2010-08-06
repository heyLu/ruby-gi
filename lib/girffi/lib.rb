require 'ffi'

module GIRepository
  module Lib
    extend FFI::Library
    ffi_lib "girepository-1.0"

    # IRepository
    enum :IRepositoryLoadFlags, [:LAZY, (1<<0)]

    attach_function :g_irepository_get_default, [], :pointer
    attach_function :g_irepository_require,
      [:pointer, :string, :string, :IRepositoryLoadFlags, :pointer],
      :pointer
    attach_function :g_irepository_get_n_infos, [:pointer, :string], :int
    attach_function :g_irepository_get_info,
      [:pointer, :string, :int], :pointer
    attach_function :g_irepository_find_by_name,
      [:pointer, :string, :string], :pointer
    attach_function :g_irepository_get_shared_library,
      [:pointer, :string], :string


    # IBaseInfo
    enum :IInfoType, [
      :invalid,
      :function,
      :callback,
      :struct,
      :boxed,
      :enum,
      :flags,
      :object,
      :interface,
      :constant,
      :error_domain,
      :union,
      :value,
      :signal,
      :vfunc,
      :property,
      :field,
      :arg,
      :type,
      :unresolved
    ]

    attach_function :g_base_info_get_type, [:pointer], :IInfoType
    attach_function :g_base_info_get_name, [:pointer], :string
    attach_function :g_base_info_get_namespace, [:pointer], :string
    attach_function :g_base_info_is_deprecated, [:pointer], :bool
    attach_function :g_base_info_equal, [:pointer, :pointer], :bool

    # IFunctionInfo
    attach_function :g_function_info_get_symbol, [:pointer], :string
    # TODO: return type is bitfield
    attach_function :g_function_info_get_flags, [:pointer], :int

    # ICallableInfo
    enum :ITransfer, [
      :nothing,
      :container,
      :everything
    ]

    attach_function :g_callable_info_get_return_type, [:pointer], :pointer
    attach_function :g_callable_info_get_caller_owns, [:pointer], :ITransfer
    attach_function :g_callable_info_may_return_null, [:pointer], :bool
    attach_function :g_callable_info_get_n_args, [:pointer], :int
    attach_function :g_callable_info_get_arg, [:pointer, :int], :pointer

    # IArgInfo
    enum :IDirection, [
      :in,
      :out,
      :inout
    ]

    enum :IScopeType, [
      :invalid,
      :call,
      :async,
      :notified
    ]

    attach_function :g_arg_info_get_direction, [:pointer], :IDirection
    attach_function :g_arg_info_is_return_value, [:pointer], :bool
    attach_function :g_arg_info_is_optional, [:pointer], :bool
    attach_function :g_arg_info_may_be_null, [:pointer], :bool
    attach_function :g_arg_info_get_ownership_transfer, [:pointer], :ITransfer
    attach_function :g_arg_info_get_scope, [:pointer], :IScopeType
    attach_function :g_arg_info_get_closure, [:pointer], :int
    attach_function :g_arg_info_get_destroy, [:pointer], :int
    attach_function :g_arg_info_get_type, [:pointer], :pointer

    enum :ITypeTag, [
      :void,  0,
      :boolean,  1,
      :int8,  2,
      :uint8,  3,
      :int16,  4,
      :uint16,  5,
      :int32,  6,
      :uint32,  7,
      :int64,  8,
      :uint64,  9,
      :short, 10,
      :ushort, 11,
      :int, 12,
      :uint, 13,
      :long, 14,
      :ulong, 15,
      :ssize, 16,
      :size, 17,
      :float, 18,
      :double, 19,
      :time_t, 20,
      :gtype, 21,
      :utf8, 22,
      :filename, 23,
      :array, 24,
      :interface, 25,
      :glist, 26,
      :gslist, 27,
      :ghash, 28,
      :error, 29
    ]

    #define G_TYPE_TAG_IS_BASIC(tag) (tag < GI_TYPE_TAG_ARRAY)

    attach_function :g_type_tag_to_string, [:ITypeTag], :string

    attach_function :g_type_info_is_pointer, [:pointer], :bool
    attach_function :g_type_info_get_tag, [:pointer], :ITypeTag
    attach_function :g_type_info_get_param_type, [:pointer, :int], :pointer
    attach_function :g_type_info_get_interface, [:pointer], :pointer
    attach_function :g_type_info_get_array_length, [:pointer], :int
    attach_function :g_type_info_get_array_fixed_size, [:pointer], :int
    attach_function :g_type_info_is_zero_terminated, [:pointer], :bool
    attach_function :g_type_info_get_n_error_domains, [:pointer], :int
    attach_function :g_type_info_get_error_domain, [:pointer, :int], :pointer

    # IStructInfo
    attach_function :g_struct_info_get_n_fields, [:pointer], :int
    attach_function :g_struct_info_get_field, [:pointer, :int], :pointer
    attach_function :g_struct_info_get_n_methods, [:pointer], :int
    attach_function :g_struct_info_get_method, [:pointer, :int], :pointer
    attach_function :g_struct_info_find_method, [:pointer, :string], :pointer
    attach_function :g_struct_info_get_size, [:pointer], :int
    attach_function :g_struct_info_get_alignment, [:pointer], :int
    attach_function :g_struct_info_is_gtype_struct, [:pointer], :bool

    # IValueInfo
    attach_function :g_value_info_get_value, [:pointer], :long

    # IFieldInfo
    enum :IFieldInfoFlags, [
      :readable, (1 << 0),
      :writable, (1 << 1)
    ]
    attach_function :g_field_info_get_flags, [:pointer], :IFieldInfoFlags
    attach_function :g_field_info_get_size, [:pointer], :int
    attach_function :g_field_info_get_offset, [:pointer], :int
    attach_function :g_field_info_get_type, [:pointer], :pointer

    # IUnionInfo
    # IStructInfo
    # IRegisteredTypeInfo

    # IEnumInfo
    attach_function :g_enum_info_get_storage_type, [:pointer], :ITypeTag
    attach_function :g_enum_info_get_n_values, [:pointer], :int
    attach_function :g_enum_info_get_value, [:pointer, :int], :pointer

    # IObjectInfo
    attach_function :g_object_info_get_type_name, [:pointer], :string
    attach_function :g_object_info_get_type_init, [:pointer], :string
    attach_function :g_object_info_get_abstract, [:pointer], :bool
    attach_function :g_object_info_get_parent, [:pointer], :pointer
    attach_function :g_object_info_get_n_interfaces, [:pointer], :int
    attach_function :g_object_info_get_interface, [:pointer, :int], :pointer
    attach_function :g_object_info_get_n_fields, [:pointer], :int
    attach_function :g_object_info_get_field, [:pointer, :int], :pointer
    attach_function :g_object_info_get_n_properties, [:pointer], :int
    attach_function :g_object_info_get_property, [:pointer, :int], :pointer
    attach_function :g_object_info_get_n_methods, [:pointer], :int
    attach_function :g_object_info_get_method, [:pointer, :int], :pointer
    attach_function :g_object_info_find_method, [:pointer, :string], :pointer
    attach_function :g_object_info_get_n_signals, [:pointer], :int
    attach_function :g_object_info_get_signal, [:pointer, :int], :pointer
    attach_function :g_object_info_get_n_vfuncs, [:pointer], :int
    attach_function :g_object_info_get_vfunc, [:pointer, :int], :pointer
    attach_function :g_object_info_find_vfunc, [:pointer, :string], :pointer
    attach_function :g_object_info_get_n_constants, [:pointer], :int
    attach_function :g_object_info_get_constant, [:pointer, :int], :pointer
    attach_function :g_object_info_get_class_struct, [:pointer], :pointer

  end
end
