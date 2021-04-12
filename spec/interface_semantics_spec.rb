require "interface_semantics"

RSpec.describe Interface do
  class Trip
  end

  TripPreparer = interface {
    prepare(Trip, Trip)
  }

  describe "initialization" do
    context "when class doesn't define interface messages" do
      let(:mechanic) do
        Class.new do
          implements TripPreparer
        end
      end

      it "raises" do
        expect { mechanic.new }.to raise_error(described_class::DoesNotImplementError)
      end
    end

    context "when class defines interface messages" do
      let(:mechanic) do
        Class.new do
          implements TripPreparer

          def prepare
            Trip.new
          end
        end
      end

      it "does not raise" do
        expect { mechanic.new }.not_to raise_error
      end
    end
  end

  describe "method call" do
    context "when incorrect arguments" do
      let(:mechanic) do
        Class.new do
          implements TripPreparer

          def prepare
            "foo"
          end
        end
      end

      it "raises" do
        expect { mechanic.new.prepare }.to raise_error(described_class::IncorrectArgumentsError)
      end
    end

    context "when incorrect return type" do
      let(:mechanic) do
        Class.new do
          implements TripPreparer

          def prepare(trip)
            "foo"
          end
        end
      end

      it "raises" do
        expect { mechanic.new.prepare(Trip.new) }.to raise_error(described_class::IncorrectReturnType)
      end
    end

    context "when correct return type" do
      let(:mechanic) do
        Class.new do
          implements TripPreparer

          def prepare(trip)
            trip
          end
        end
      end

      it "does not raise" do
        expect { mechanic.new.prepare(Trip.new) }.not_to raise_error
      end
    end
  end
end
