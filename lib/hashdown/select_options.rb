module Hashdown
  module SelectOptions
    def selectable(*args)
      unless respond_to?(:select_options)
        extend ClassMethods
        include InstanceMethods

        after_save    :clear_select_options_cache
        after_destroy :clear_select_options_cache

        class << self
          attr_accessor :select_options_options
        end
      end

      options = args.pop if args.last.is_a?(Hash)
      options ||= {}

      options[:label] ||= args.shift || :name
      options[:value] ||= args.shift || :id

      self.select_options_options = options
    end

    module ClassMethods
      def select_options(*args)
        options = args.pop if args.last.is_a?(Hash)
        options ||= {}

        options[:label] ||= args.shift if args.any?
        options[:value] ||= args.shift if args.any?
        options.reverse_merge!(select_options_options)

        scope = scoped
        options[:is_sorted] = scope.arel.orders.any?
        scope = select_options_scope_with_order(scope, options)

        cache_key = Hashdown.cache_key(:select_options, self.to_s, select_options_cache_key(options, scope))

        Hashdown.cache.fetch(cache_key, :force => Hashdown.force_cache_miss?) do
          if grouping = options[:group]
            scope.all.group_by {|record| grouping.call(record) }.map do |group, records|
              [group, map_records_to_select_options(records, options)]
            end
          else
            map_records_to_select_options(scope.all, options)
          end
        end
      end

      private

      def select_options_cache_key(options, scope)
        key = options.sort.each_with_object(""){|ck,(k,v)| ck << "#{ k }:#{ v };" }
        key << scope.to_sql
        key = Digest::MD5.hexdigest(key)
      end

      def map_records_to_select_options(records, options)
        records = records.map { |record| select_option_for_record(record, options) }
        options[:is_sorted] ? records : records.sort
      end

      def select_option_for_record(record, options)
        [ record.send(options[:label]), record.send(options[:value]) ]
      end

      def select_options_scope_with_order(scope, options)
        unless options[:is_sorted]
          if columns.any? { |c| c.name == options[:label].to_s }
            options[:is_sorted] = true
            return scope.order(options[:label])
          end
        end

        scope
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
