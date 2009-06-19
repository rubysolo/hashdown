module Rubysolo # :nodoc:
  module Hashdown

    module Finder
      def self.included(base)
        base.instance_eval do
          validates_uniqueness_of finder_attribute

          cattr_accessor :cache_store
          self.cache_store ||= ActiveSupport::Cache::MemoryStore.new

          def self.[](token)
            cache_store.fetch("[]:#{token}", :force => Rubysolo::Hashdown.force_cache_miss?) {
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
    end # Finder

  end
end
