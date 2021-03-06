require 'gir_ffi/builder/type/struct_based'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing an Interface.
      class Interface < RegisteredType
        def build_class
          unless defined? @klass
            instantiate_module
          end
          @klass
        end

        def instantiate_module
          @klass = optionally_define_constant(namespace_module, @classname) do
            ::Module.new do
              def self.gir_ffi_builder
                const_get :GIR_FFI_BUILDER
              end
            end
          end
          setup_module unless already_set_up
        end

        def setup_module
          setup_constants
          stub_methods
        end
      end
    end
  end
end

