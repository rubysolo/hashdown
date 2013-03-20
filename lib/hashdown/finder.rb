require 'hashdown/cache'

module Hashdown
  module Finder
    def finder(attribute, options={})
      self.extend ClassMethods
      self.send(:include, InstanceMethods)

      hashdown.finder = Config.new(options.merge(:key => attribute))

      validates attribute, :uniqueness => true

      after_save :clear_hashdown_finder_cache
      after_destroy :clear_hashdown_finder_cache
    end

    module ClassMethods
      def hashdown
        @hashdown ||= Config.new
      end

      def [](token)
        cache_key = Hashdown.cache_key(:finder, self.to_s, token)

        Hashdown.cache.fetch(cache_key, :force => Hashdown.force_cache_miss?) do
          where({hashdown.finder.key => token.to_s}).first || hashdown_default_or_raise
        end
      end

      private

      def hashdown_default_or_raise
        raise ActiveRecord::RecordNotFound unless hashdown.finder.default?
        hashdown.finder.default
      end
    end

    module InstanceMethods
      def hashdown
        self.class.hashdown
      end

      def clear_hashdown_finder_cache
        Hashdown.uncache(:finder, self.class.to_s, self[hashdown.finder.key])
      end
    end
  end
end

ActiveRecord::Base.extend Hashdown::Finder
