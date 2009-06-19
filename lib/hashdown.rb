require 'activesupport' unless defined? ActiveSupport
require 'activerecord'  unless defined? ActiveRecord
require 'finder'
require 'selectable'

module Rubysolo # :nodoc:
  module Hashdown
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def finder(attr_name)
        class << self
          attr_accessor :finder_attribute
        end
        self.finder_attribute = attr_name

        self.send :include, Finder
      end

      def selectable(options={})
        class << self
          attr_accessor :selectable_options
        end
        self.selectable_options = options

        self.send :include, Selectable
      end
    end

    private

    def self.force_cache_miss?
      defined?(Rails) && Rails.env.test?
    end


  end # Hashdown
end # Rubysolo
