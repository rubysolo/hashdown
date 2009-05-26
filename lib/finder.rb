module ActiveRecord # :nodoc:
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

        self.send(:include, Finder)
        (class << self; self; end).module_eval do
          alias_method "for_#{attr_name}".to_sym, :[]
        end
      end
    end

    module Finder
      def self.included(base)
        base.instance_eval do
          cattr_accessor :cache_store
          self.cache_store = ActiveSupport::Cache::MemoryStore.new

          def self.[](token)
            cache_store.fetch(token) { find(:first, :conditions => { finder_attribute => token.to_s}) }
          end
        end
      end
    end
  end
end
