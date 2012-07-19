# Hashdown

Hashdown is a super lightweight rails plugin that adds hash-style lookups and
option lists (for generating dropdowns) to ActiveRecord models.  Note: Hashdown
has been updated to support Rails 3.  If you're looking for the original plugin
version, it's in the [rails 2 branch](https://github.com/rubysolo/hashdown/tree/rails2)

## Installation

Add this line to your application's Gemfile:

    gem 'hashdown'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hashdown

## Usage

Given the following class definition:

    class State < ActiveRecord::Base
      finder :abbreviation
    end

You can look up states via their abbreviations like so:

    @colorado = State[:CO]

By default, calling the finder method with a token that does not exist in the
database will result in an ActiveRecord::RecordNotFount exception being thrown.
This can be overridden by adding a :default option to your finder declaration.

    class PurchaseOrder < ActiveRecord::Base
      finder :number, :default => nil
    end

In this case, PurchaseOrder['00734'] will silently return nil if that number is
not found.

These types of reference data models are often something you need to populate a
select list on your form, so hashdown includes a method to generate your option
list:

1. Declare your model to be selectable:

    class State < ActiveRecord::Base
      selectable
    end

2. Call select_options in your form to return a set of name, value pairs to
pass into a select builder:

    <%= form.select :state_id, State.select_options %>

By default, selectable will return the :id of the record as the value, and the
:name attribute value as the display.  This can be overridden inline in the
select_options call:

    State.select_options(:name, :abbreviation)

The grouped_options_for_select format is also supported:

    State.select_options(:group => :region)

Adding finder and selectable to a model is roughly equivalent to the following
implementation:

    class State < ActiveRecord::Base
      validates_uniqueness_of :abbreviation

      def self.[](state_code)
        find_by_abbreviation(state_code)
      end

      def self.select_options
        find(:all).map{|s| [s.name, s.id] }
      end
    end

...except hashdown adds configuration for flexibility and caching for speedy
lookups.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
