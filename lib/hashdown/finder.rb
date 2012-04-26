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
        Hashdown.cache.fetch(Hashdown.cache_key(:finder, self.to_s, token), :force => Hashdown.force_cache_miss?) do
          where({hashdown.finder.key => token.to_s}).first || (
            hashdown.finder.default? ?
              hashdown.finder.default :
              raise(ActiveRecord::RecordNotFound)
          )
        end
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
