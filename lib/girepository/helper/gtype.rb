require 'ffi'

module GIRepository
  module Helper
    module GType
      extend FFI::Library
      def self.attach_function_private name, a1, a2, a3=nil
	attach_function name, a1, a2, a3
	private_class_method a3.nil? ? name : a1
      end

      ffi_lib "gobject-2.0"
      attach_function_private :g_type_init, [], :void
      def self.init; g_type_init; end
    end
  end
end
