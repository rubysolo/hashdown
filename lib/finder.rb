require 'activesupport' unless defined? ActiveSupport
require 'activerecord' unless defined? ActiveRecord

module Rubysolo # :nodoc:
  module Finder
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def finder(attr_name)
        class << self
          attr_accessor :finder_attribute
        end
        self.finder_attribute = attr_name

        self.send(:include, FindableModel)
        (class << self; self; end).module_eval do
          alias_method "for_#{attr_name}".to_sym, :[]
        end
      end
    end

    module FindableModel
      def self.included(base)
        base.instance_eval do
          validates_uniqueness_of finder_attribute

          cattr_accessor :cache_store
          self.cache_store = ActiveSupport::Cache::MemoryStore.new

          def self.[](token)
            cache_store.fetch(token) {
              returning find(:first, :conditions => { finder_attribute => token.to_s}) do |record|
                raise "Could not find #{self.class_name} with #{finder_attribute} '#{token}'" unless record
              end
            }
          end
        end
      end

      def is?(token)
        self[self.class.finder_attribute] == token.to_s
      end
    end
  end
end
