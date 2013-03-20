require 'pry-nav'
require 'rspec'
require 'rspec/autorun'

require 'sqlite3'
require 'active_record'
require 'hashdown/finder'
require 'hashdown/select_options'

ActiveRecord::Base.establish_connection(:adapter  => 'sqlite3', :database => ':memory:')
load 'support/models.rb'

module Hashdown
  def self.reset
    @cache = @rails = nil
  end
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:each) do
    ActiveRecord::Base.establish_connection(:adapter  => 'sqlite3', :database => ':memory:')
    load 'support/schema.rb'
    load 'support/seeds.rb'

    Hashdown.reset
  end

  config.after(:each) do
    Hashdown.reset
  end
end
