require 'spec'
require 'mocha'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require File.join(File.dirname(__FILE__), '..', 'init')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.verbose = false
  ActiveRecord::Schema.define(:version => 1) do
    create_table :states do |t|
      t.string :name, :abbreviation
    end
  end
end

def load_fixtures
  YAML.load(IO.read(File.dirname(__FILE__) + '/fixtures/states.yml')).each do |name, attrs|
    State.create!(attrs)
  end
end

setup_db

def cleanup_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.execute("delete from #{table}")
  end
end

class State < ActiveRecord::Base
  finder :abbreviation
end
