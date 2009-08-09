require 'spec'
require 'mocha'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require File.join(File.dirname(__FILE__), '..', 'init')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.verbose = false
  ActiveRecord::Schema.define(:version => 1) do
    create_table :states do |t|
      t.string :name, :abbreviation
    end

    create_table :currencies do |t|
      t.string :name, :code
    end
  end
end

def load_fixtures
  %w( states currencies ).each do |fixture|
    YAML.load(IO.read(File.dirname(__FILE__) + "/fixtures/#{fixture}.yml")).each do |name, attrs|
      Object.const_get(fixture.singularize.classify).create!(attrs)
    end
  end
end

setup_db

def cleanup_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.execute("delete from #{table}")
  end
end

class Rails
  cattr_accessor :test_environment

  def self.env
    self
  end

  def self.test?
    @@test_environment
  end
end

class State < ActiveRecord::Base
  finder :abbreviation
  selectable
end

class CustomDisplay < ActiveRecord::Base
  selectable
  set_table_name 'states'

  def display_name
    "custom #{name}"
  end
end

class CustomDisplayDeux < ActiveRecord::Base
  selectable :value => :abbreviation
  set_table_name 'states'
end

class Currency < ActiveRecord::Base
  selectable
  default_scope :order => "code"
end
