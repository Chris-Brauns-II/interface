require "interface"
require "pry"

Employee = interface {
  employed?
}

RSpec.describe Interface do
  describe "initialization" do
    context "when class doesn't define interface messages" do
      let(:employee_class) do
        Class.new do
          implements Employee
        end
      end

      it "raises" do
        expect { employee_class.new }.to raise_error(described_class::DoesNotImplementError)
      end
    end

    context "when class defines interface messages" do
      let(:employee_class) do
        Class.new do
          implements Employee

          def employed?; end
        end
      end

      it "does not raise" do
        expect { employee_class.new }.not_to raise_error
      end
    end
  end
end
