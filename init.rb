require 'hashdown'
ActiveRecord::Base.class_eval do
  include Rubysolo::Hashdown
end
