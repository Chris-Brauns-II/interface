Class.class_eval do
  def implements(mod)
    include mod
  end
end

def interface(&block)
  Interface.for_messages(&block)
end

module Interface
  DoesNotImplementError = Class.new(StandardError)

  def self.for_messages(&block)
    attributes = DSL.run(&block)

    Module.new do
      module_eval("def run_checks; " + attributes.map { |a| "raise DoesNotImplementError unless self.respond_to?(:#{a});" }.join("") + "end")

      def initialize
        after_initialize
      end

      def after_initialize
        run_checks
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
    check_message(name)
  end

  def check_message(name)
    attributes << name
  end
end