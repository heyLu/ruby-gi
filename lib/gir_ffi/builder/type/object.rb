require 'gir_ffi/builder/type/struct_based'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing a GObject Object.
      class Object < StructBased
        def setup_method method
          if super
            return true
          else
            if parent
              return superclass.gir_ffi_builder.setup_method method
            else
              return false
            end
          end
        end

        def setup_instance_method method
          if super
            return true
          else
            info.interfaces.each do |ifinfo|
              iface = GirFFI::Builder.build_class ifinfo
              if iface.gir_ffi_builder.setup_instance_method method
                return true
              end
            end
            if parent
              return superclass.gir_ffi_builder.setup_instance_method method
            else
              return false
            end
          end
        end

        private

        def setup_class
          super
          setup_vfunc_invokers
          setup_interfaces
        end

        def parent
          unless defined? @parent
            pr = info.parent
            if pr.nil? or (pr.name == @classname and pr.namespace == @namespace)
              @parent = nil
            else
              @parent = pr
            end
          end
          @parent
        end

        def setup_vfunc_invokers
          info.vfuncs.each do |vfinfo|
            invoker = vfinfo.invoker
            next if invoker.nil?
            next if invoker.name == vfinfo.name

            @klass.class_eval "
              def #{vfinfo.name} *args, &block
                #{invoker.name}(*args, &block)
              end
            "
          end
        end

        def setup_interfaces
          info.interfaces.each do |ifinfo|
            iface = GirFFI::Builder.build_class ifinfo
            @klass.class_eval do
              include iface
            end
          end
        end

        def signal_definers
          [info] + info.interfaces
        end
      end
    end
  end
end

