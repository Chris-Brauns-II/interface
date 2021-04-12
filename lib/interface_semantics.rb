Class.class_eval do
  def implements(mod)
    prepend mod
  end
end

Message = Struct.new(:name, :argument_types, :return_type)

def interface(&block)
  Interface.for_messages(&block)
end

module Interface
  DoesNotImplementError = Class.new(StandardError)
  IncorrectReturnType = Class.new(StandardError)
  IncorrectArgumentsError = Class.new(StandardError)

  def self.for_messages(&block)
    messages = DSL.run(&block)

    Module.new do
      init = <<-RUBY
        def initialize(*)
          super
          after_initialize
        end
      RUBY

      messages.each do |a|
        argument_checks = a.argument_types.each_with_index.map do |at, i|
          "raise IncorrectArgumentsError unless args[#{i}].class == #{at.name};"
        end.join(" ")

        method_wrapper = "def #{a.name}(*args); #{argument_checks} super.tap do |return_val| raise IncorrectReturnType unless return_val.class == #{a.return_type}; end; end"

        module_eval(method_wrapper)
      end

      module_eval(init)

      module_eval("def run_checks; " + messages.map { |a| "raise DoesNotImplementError, :#{a.name} if self.method(:#{a.name}).super_method.nil?;" }.join("") + "end")

      def after_initialize
        run_checks
      end
    end
  end
end

class DSL
  attr_reader :messages

  def self.run(&block)
    dsl = new
    dsl.instance_eval(&block)
    dsl.messages
  end

  def initialize
    @messages = []
  end

  def method_missing(name, *args, **kwargs)
    messages << Message.new(name, args[0..-2], args.last)
  end
end