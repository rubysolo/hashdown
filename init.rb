require 'finder'
ActiveRecord::Base.class_eval do
  include Rubysolo::Finder
end
