module Hashdown
  module SelectOptions
    def select_options(*args)
      unless self.respond_to?(:map_records_to_select_options)
        self.extend ClassMethods
        self.send(:include, InstanceMethods)

        after_save    :clear_select_options_cache
        after_destroy :clear_select_options_cache
      end

      options = args.pop if args.last.is_a?(Hash)
      options ||= {}

      options[:label] ||= args.shift || :name
      options[:value] ||= args.shift || :id

      scope = scoped
      scope = scope.order(options[:label]) if scope.arel.orders.empty? && columns.any?{|c| c.name == options[:label].to_s }

      Hashdown.cache.fetch(Hashdown.cache_key(:select_options, self.to_s, select_options_cache_key(options, scope)), :force => Hashdown.force_cache_miss?) do
        if grouping = options[:group]
          scope.all.group_by {|record| grouping.call(record) }.map do |group, records|
            [group, map_records_to_select_options(records, options)]
          end
        else
          map_records_to_select_options(scope.all, options)
        end
      end
    end

    module ClassMethods
      private

      def select_options_cache_key(options, scope)
        key = options.sort.each_with_object(""){|ck,(k,v)| ck << "#{ k }:#{ v };" }
        key << scope.to_sql
        key = Digest::MD5.hexdigest(key)
      end

      def map_records_to_select_options(records, options)
        records.map{|record| [ record[options[:label]], record[options[:value]] ] }
      end
    end

    module InstanceMethods
      private

      def clear_select_options_cache
        Hashdown.cache.delete_matched(Regexp.new(Hashdown.cache_key(:select_options, self.class.to_s)))
      end
    end
  end
end

ActiveRecord::Base.extend Hashdown::SelectOptions
