Class.class_eval do
  def implements(mod)
    prepend mod
  end
end

Attribute = Struct.new(:name, :type)

def interface(&block)
  Interface.for_messages(&block)
end

module Interface
  DoesNotImplementError = Class.new(StandardError)
  IncorrectReturnType = Class.new(StandardError)

  def self.for_messages(&block)
    attributes = DSL.run(&block)

    Module.new do
      module_eval("def run_checks; " + attributes.map { |a| "raise DoesNotImplementError, :#{a.name} if self.method(:#{a.name}).super_method.nil?;" }.join("") + "end")

      attributes_string = attributes.map { |a| "Attribute.new(:#{a.name}, #{a.type})" }.join(",")
      init = <<-RUBY
        def initialize
          @attributes = [#{attributes_string}]
          after_initialize
        end
      RUBY

      attributes.each do |a|
        method_wrapper = <<-RUBY
          def #{a.name}(*)
            super.tap do |return_val|
              raise IncorrectReturnType unless return_val.class == #{a.type}
            end
          end
        RUBY

        module_eval(method_wrapper)
      end

      module_eval(init)

      def after_initialize
        run_checks
      end

      def return_value(value)
        c = caller[0]
        (_, method) = c.split(/`([a-zA-Z!?_]+)'/)
        raise IncorrectReturnType unless @attributes.detect { |a| a.name == method.to_sym }.type == value.class
        value
      end

      def self.included(base)
        base.const_set(:Interface_Attributes, self)
      end
    end
  end
end


class DSL
  attr_reader :attributes

  def self.run(&block)
    dsl = new
    dsl.instance_eval(&block)
    dsl.attributes
  end

  def initialize
    @attributes = []
  end

  def method_missing(name, *args, **kwargs)
    attributes << Attribute.new(name, args.first)
  end
end