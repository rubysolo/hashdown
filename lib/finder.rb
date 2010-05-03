module Rubysolo # :nodoc:
  module Hashdown

    module Finder
      def self.included(base)
        base.instance_eval do
          validates_uniqueness_of finder_options[:attribute]

          cattr_accessor :cache_store
          self.cache_store ||= ActiveSupport::Cache::MemoryStore.new
          after_save :clear_finder_cache
          after_destroy :clear_finder_cache

          def self.[](token)
            cache_store.fetch("[]:#{token}", :force => Rubysolo::Hashdown.force_cache_miss?) {
              record = find(:first, :conditions => { finder_options[:attribute] => token.to_s })
              if finder_options.has_key?(:default)
                record ||= finder_options[:default]
              else
                raise "Could not find #{self.class_name} with #{finder_options[:attribute]} '#{token}'" unless record
              end
              record
            }
          end
        end
      end

      def is?(token)
        self[self.class.finder_attribute] == token.to_s
      end

      private

      def clear_finder_cache
        self.class.cache_store.clear
      end
    end # Finder

  end
end
