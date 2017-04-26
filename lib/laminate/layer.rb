require 'forwardable'

module Laminate
  module Layer
    def with_layer(layer_module, options = {})
      with_layers(Array(layer_module), options)
    end

    def with_layers(layer_modules, options = {})
      # If layer_module isn't a ruby module, blow up.
      unless layer_modules.all? { |mod| mod.is_a?(Module) }
        raise ArgumentError, 'layers must all be modules'
      end

      # Grab the cache from the super class's singleton. It's not correct to
      # simply reference the @@__laminate_layer_cache variable because of
      # lexical scoping. If we were to reference the variable directly, Ruby
      # would think we wanted to associate it with the Layer module, where in
      # reality we want to associate it with each module Layer is mixed into.
      cache = self.class.class_variable_get(:@@__laminate_layer_cache)

      # We don't want to generate each wrapper class more than once, so keep
      # track of the modules => dynamic wrapper mapping and avoid re-creating
      # them on every call to with_layer.
      cache[layer_modules] ||= begin
        layer_module_methods = layer_modules.flat_map do |mod|
          mod.instance_methods(false)
        end

        unless options.fetch(:allow_overrides, false)
          # Identify method collisions. In order to minimize accidental
          # monkeypatching, Celophane will error if you try to wrap an object
          # with a layer that defines any method with the same name as a method
          # the object already responds to. Starts with self, or more accurately,
          # the methods defined on self. The loop walks the ancestor chain an
          # checks each ancestor for previously defined methods.
          ancestor = self

          while ancestor
            # Filter out Object's methods, which are common to all objects and not
            # ones we should be forwarding. Also filter out Layer's methods for
            # the same reason.
            ancestor_methods = ancestor.class.instance_methods - (
              Object.methods + Layer.instance_methods(false)
            )

            # Calculate the intersection between the layer's methods and the
            # methods defined by the current ancestor.
            already_defined = ancestor_methods & layer_module_methods

            unless already_defined.empty?
              ancestor_modules = [self.class] + (ancestor.instance_variable_get(:@__laminate_modules) || [])

              error_messages = already_defined.map do |method_name|
                ancestor_module = ancestor_modules.find do |mod|
                  mod.method_defined?(method_name)
                end

                "  `##{method_name}' is already defined by #{ancestor_module.name}"
              end

              layer_plural = error_messages.size == 1 ? 'layer' : 'layers'

              # @TODO: fix the English here
              raise MethodAlreadyDefinedError,
                "Unable to add #{layer_plural} (pass `allow_overrides: true` if "\
                  "intentional):\n#{error_messages.join("\n")}"
            end

            # Grab the next ancestor and keep going. The loop exits when ancestor
            # is nil, which happens whenever the end of the ancestor chain has
            # been reached (i.e. when iteration reaches the base object).
            ancestor = ancestor.instance_variable_get(:@__laminate_ancestor)
          end
        end

        ancestor_methods = self.class.instance_methods - (
          Object.methods + Layer.instance_methods(false) + layer_module_methods
        )

        # Dynamically define a new class and mix in the layer modules. Forward
        # all the ancestor's methods to the ancestor. Dynamic layer classes keep
        # track of both the ancestor itself as well as the modules it was
        # constructed from.
        klass = Class.new do
          layer_modules.each do |layer_module|
            include layer_module
          end

          extend Forwardable

          # Forward all the ancestor's methods to the ancestor.
          def_delegators :@__laminate_ancestor, *ancestor_methods

          def initialize(ancestor, layer_modules)
            # Use absurd variable names to avoid re-defining instance variables
            # introduced by the layer module.
            @__laminate_ancestor = ancestor
            @__laminate_modules = layer_modules
          end
        end

        module_names = layer_modules.map { |mod| mod.name.split('::').last }
        wrapper_name = 'With' + module_names.join('And')

        # Assign the new wrapper class to a constant inside self, with 'With'
        # prepended. For example, if the module is called Engine the wrapper
        # class will be assigned to a constant named WithEngine.
        self.class.const_set(wrapper_name, klass)
        klass
      end

      # Wrap self in a new instance of the wrapper class.
      cache[layer_modules].new(self, layer_modules)
    end

    def self.included(base)
      base.class_variable_set(:@@__laminate_layer_cache, {})
    end
  end
end
