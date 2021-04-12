[![Gem Version](https://badge.fury.io/rb/interface_semantics.svg)](https://badge.fury.io/rb/interface_semantics)
# Interface Semantics

A gem for making interfaces

# Usage

```
gem install interface_semantics
```
# Example

```ruby
class Trip
  attr_reader :preparers

  def initialize(preparers)
    @preparers = preparers
  end

  def prepare
    preparers.each { |p| p.prepare(self) }
  end
end

TripPreparer = interface {
  prepare(Trip, Trip)
}

class Mechanic
  implements TripPreparer

  def initialize
    puts "new Mechanic created"
  end

  def prepare(trip)
    puts "clean the bikes"
    trip
  end
end

class TravelAgent
  implements TripPreparer

  def prepare(trip)
    puts "book tickets"
    trip
  end
end

Trip.new([
  Mechanic.new,
  TravelAgent.new
]).prepare
```