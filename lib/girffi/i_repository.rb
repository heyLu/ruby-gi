require 'singleton'
require 'girffi/lib'
require 'girffi/g_type'
require 'girffi/g_error'
require 'girffi/i_base_info'
require 'girffi/i_callable_info'
require 'girffi/i_callback_info'
require 'girffi/i_function_info'
require 'girffi/i_constant_info'
require 'girffi/i_field_info'
require 'girffi/i_registered_type_info'
require 'girffi/i_interface_info'
require 'girffi/i_property_info'
require 'girffi/i_vfunc_info'
require 'girffi/i_signal_info'
require 'girffi/i_object_info'
require 'girffi/i_struct_info'
require 'girffi/i_value_info'
require 'girffi/i_union_info'
require 'girffi/i_enum_info'
require 'girffi/i_flags_info'

module GIRepository
  # The Gobject Introspection Repository. This class is the point of
  # access to the introspection typelibs.
  # This class wraps the GIRepository struct.
  class IRepository
    TYPEMAP = {
      #:invalid,
      :function => IFunctionInfo,
      :callback => ICallbackInfo,
      :struct => IStructInfo,
      #:boxed => ,
      :enum => IEnumInfo,
      :flags => IFlagsInfo,
      :object => IObjectInfo,
      :interface => IInterfaceInfo,
      :constant => IConstantInfo,
      # :error_domain,
      :union => IUnionInfo,
      :value => IValueInfo,
      :signal => ISignalInfo,
      :vfunc => IVFuncInfo,
      :property => IPropertyInfo,
      :field => IFieldInfo,
      :arg => IArgInfo,
      :type => ITypeInfo,
      #:unresolved
    }

    def initialize
      GObject.type_init
      @gobj = Lib::g_irepository_get_default
    end

    include Singleton

    def self.default
      self.instance
    end

    def self.type_tag_to_string type
      Lib.g_type_tag_to_string type
    end

    def n_infos namespace
      Lib.g_irepository_get_n_infos @gobj, namespace
    end

    def require namespace, version
      errpp = FFI::MemoryPointer.new(:pointer).write_pointer nil

      Lib.g_irepository_require @gobj, namespace, version, 0, errpp

      errp = errpp.read_pointer
      raise GError.new(errp)[:message] unless errp.null?
    end

    def info namespace, index
      ptr = Lib.g_irepository_get_info @gobj, namespace, index
      return wrap ptr
    end

    def find_by_name namespace, name
      ptr = Lib.g_irepository_find_by_name @gobj, namespace, name
      return wrap ptr
    end

    def shared_library namespace
      Lib.g_irepository_get_shared_library @gobj, namespace
    end

    def self.wrap_ibaseinfo_pointer ptr
      return nil if ptr.null?

      type = Lib.g_base_info_get_type ptr
      klass = TYPEMAP[type]

      return klass.wrap(ptr)
    end

    private

    def wrap ptr
      IRepository.wrap_ibaseinfo_pointer ptr
    end
  end
end
