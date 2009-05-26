require 'finder'
ActiveRecord::Base.class_eval do
  include ActiveRecord::Finder
end
